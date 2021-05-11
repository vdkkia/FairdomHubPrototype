require "test_helper"
class SinglePagesControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper

  def setup
    @member = Factory :user
    @project = @member.person.projects.first
    login_as @member
  end

  test 'should show' do
    project = Factory(:project)
    get :show, params: { id: project.id }
    assert_response :success
  end

  test 'should redirect if not enabled' do
    with_config_value(:project_single_page_enabled, false) do
      project = Factory(:project)
      get :show,  params: { id: project.id }
      assert_redirected_to project_path(project)
    end
  end

  test 'should prepare assets for sharing form' do
    project = Factory(:project)
    investigation = Factory(:investigation)
    study = Factory(:study)
    assay = Factory(:assay, assay_assets: [Factory(:assay_asset, asset:Factory(:sop))])

    get :render_sharing_form , params: { id: investigation.id, type: "investigation" }, format: :js 
    assert_response :success
    get :render_sharing_form , params: { id: study.id, type: "study" }, format: :js 
    assert_response :success
    get :render_sharing_form , params: { id: assay.id, type: "assay" }, format: :js 
    assert_response :success
    get :render_sharing_form , params: { id: -1, type: "assay" }, format: :js 
    assert_response :unprocessable_entity
    
  end


  test 'should create flowchart if not exist' do
    project = Factory(:project)
    study = Factory(:study)
    items = { id: 1, left: 2, top: 3 }
    flowchart = { study_id: study.id, items: JSON.generate(items)}
    post :update_flowchart, params: { id: project.id, flowchart: flowchart } 
    body = JSON.parse(response.body)
    assert body.include?('data')
    assert body['data'].include?('id')
    assert_equal body['is_new'], true
  end

  test 'should update flowchart' do
    project = Factory(:project)
    flowchart = Factory(:flowchart)
    items = { id: 2, left: 3, top: 4 }
    new_flowchart = { study_id: flowchart.study_id, items: JSON.generate(items)}
    post :update_flowchart, params: { id: project.id, flowchart: new_flowchart } 
    body = JSON.parse(response.body)
    assert body.include?('data')
    assert body['data'].include?('id')
    assert_equal body['is_new'], false
    assert_equal body['data']['items'], JSON.generate(items)
  end


  test 'should return empty object when no flowchart' do
    project = Factory(:project)
    study = Factory(:study)
    get :flowchart, params: { id: project.id, study_id: study.id }
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal body, {}
  end

  test 'should return flowchart' do
    project = Factory(:project)
    flowchart = Factory(:flowchart)
    get :flowchart, params: { id: project.id, study_id: flowchart.study_id }
    assert_response :success
    body = JSON.parse(response.body)
    assert body.include?('data')
    assert body['data'].include?('operators')
    assert body['data'].include?('links')
    assert_equal body['data']['links'].length, 1
    assert_equal body['data']['operators'].length, 2
  end

  test 'should provide the Source types list' do
    populate_source_types
    source_types = @controller.send(:load_templates)

    assert_equal source_types.kind_of?(Array), true
    source_type = source_types[0]
    assert_equal source_type[:title], 'Plant-ArrayExpress'
    assert_equal source_type[:type], "study"
    assert_equal source_type[:attributes].kind_of?(Array), true
    assert_equal source_type[:attributes][0][:title], 'protocol type'
    assert_equal source_type[:attributes][0][:required], false
  end

  test 'should return sample table' do
  end

  test 'should return nil if assay doesnt have position' do
    setup_entities
    samples = @controller.send :load_samples, @assay3, @st1 
    assert_nil samples

  end

  test 'should load samples' do
    setup_entities
    sample_collections = @controller.send :load_samples, @assay1, @st0 
    link_ids = []
    sample_collections.each do |key, collection|
      collection.each_with_index do |sample, i|
        if key == 0 
          link_ids.push(sample[:link_id])
        else
          assert_equal sample[:link_id], link_ids[i]
        end
        assert_equal true, sample.kind_of?(Sample)
      end
    end
  end

  test 'should load Ontologies' do
    cvId = populate_source_types
    query = "hal"
    get :ontology, params: {id: "1", sample_controlled_vocab_id: cvId,  query: query, format: 'json' }
    assert_response :success
    data = JSON.parse(response.body)["data"]
    assert_equal data.length, 2
    data.each do |d|
      assert_includes d["label"].downcase, query.downcase
    end
  end

  private

  def populate_source_types
    project = Factory(:project)
    r = RepositoryStandard.new(title: "Plant-ArrayExpress", group: "arrayexpress", level: "study", projects:[project])
    attribute = TemplateAttribute.new({title: "protocol type", required: "false"})
    v = SampleControlledVocab.new(title: "Organism", description:"description")
    
    v.sample_controlled_vocab_terms.new(label: "synthetic construct")
    v.sample_controlled_vocab_terms.new(label: "freshwater sediment metagenome")
    v.sample_controlled_vocab_terms.new(label: "Haloferax volcanii")
    v.sample_controlled_vocab_terms.new(label: "Halobacterium salinarum")
    v.save!

    attribute.sample_controlled_vocab_id = v.id
    r.template_attributes << attribute
    r.save!
    return v.id
  end


  def setup_entities
    person = User.current_user.person
    study = Factory(:min_study, contributor: person, policy: Factory(:public_policy))

    @st0 = SampleType.new title: 'st0', project_ids: [@project.id] , contributor: person
    @st0.sample_attributes << Factory(:sample_attribute, title: 'some_field', is_title: true, required: true, sample_attribute_type: Factory(:string_sample_attribute_type), sample_type: @st0)
    @st0.sample_attributes << Factory(:sample_attribute, title: 'another_field', sample_attribute_type: Factory(:string_sample_attribute_type), required: false, sample_type: @st0)
    # @st0.sample_attributes << Factory(:sample_attribute, title: 'link_id', sample_attribute_type: Factory(:string_sample_attribute_type), required: true, sample_type: @st0)
    @st0.save!

    @st1 = SampleType.new title: 'st1', project_ids: [@project.id] , contributor: person
    @st1.sample_attributes << Factory(:sample_attribute, title: 'organism', is_title: true, required: true, sample_attribute_type: Factory(:string_sample_attribute_type), sample_type: @st1)
    @st1.sample_attributes << Factory(:sample_attribute, title: 'organism part', sample_attribute_type: Factory(:string_sample_attribute_type), required: false, sample_type: @st1)
    # @st1.sample_attributes << Factory(:sample_attribute, title: 'link_id', sample_attribute_type: Factory(:string_sample_attribute_type), required: true, sample_type: @st1)
    @st1.save!

    st2 = SampleType.new title: 'st2', project_ids: [@project.id] , contributor: person
    st2.sample_attributes << Factory(:sample_attribute, title: 'organism', is_title: true, required: true, sample_attribute_type: Factory(:string_sample_attribute_type), sample_type: st2)
    st2.sample_attributes << Factory(:sample_attribute, title: 'organism part', sample_attribute_type: Factory(:string_sample_attribute_type), required: false, sample_type: st2)
    # st2.sample_attributes << Factory(:sample_attribute, title: 'link_id', sample_attribute_type: Factory(:string_sample_attribute_type), required: true, sample_type: st2)
    st2.save!

    @assay1 = Factory(:min_assay, contributor: person, policy: Factory(:public_policy))
    @assay1.position = 0;
    @assay1.study = study
    @assay1.sample_type_id = @st1.id
    @assay1.save!

    assay2 = Factory(:min_assay, contributor: person, policy: Factory(:public_policy))
    assay2.position = 1;
    assay2.study = study
    assay2.sample_type_id = st2.id
    assay2.save!

    @assay3 = Factory(:min_assay, contributor: person, policy: Factory(:public_policy))
    @assay3.study = study
    @assay3.save!

    sample0 = Sample.new(sample_type: @st0, contributor: person, project_ids: [@project.id], link_id: '7c0dm3d')
    sample0.update_attributes(data: { some_field: 'some_field 0', another_field: 'another_field 0' })
    sample1 = Sample.new(sample_type: @st1, contributor: person, project_ids: [@project.id], link_id: '7c0dm3d')
    sample1.update_attributes(data: { organism: 'organism 1', "organism part": 'organism part 1' })
    sample2 = Sample.new(sample_type: st2, contributor: person, project_ids: [@project.id], link_id: '7c0dm3d')
    sample2.update_attributes(data: { organism: 'organism 2', "organism part": 'organism part 2' })
  end

end
