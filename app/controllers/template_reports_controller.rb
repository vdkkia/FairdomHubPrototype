class TemplateReportsController < ApplicationController
  respond_to :html
  before_action :init, only: [:index]

  def query_samples
    init
    # template_ids = template_report_params["template_ids"] 
    template_ids = [4,5]
    @template_samples = ["s","d"]

    # @headers = RepositoryStandard.where(id: template_ids).map {|t| {
    #   :repository_standard_id => t.id,
    #    :attributes => t.template_attributes.pluck(:title)}}

    arr = []
    # # Get all project ids
    project_ids = (RepositoryStandard.where(id: template_ids).map {|t| t.sample_types.map {|s| s.projects.pluck(:id)}}).flatten.uniq
    Project.where(id: project_ids).each do |p|
      item = {:pid => p.id, :data => []}
      p.studies.each do |s|
        tr = {:template => nil, :samples => []}
        s_sample_type = SampleType.find(s.flowchart.source_sample_type_id)
        s_template = s_sample_type.repository_standard
        if (template_ids.include?(s_template.id))
          attributes = s_template.template_attributes.pluck(:title)
          tr[:template] = s_template.title
          tr[:samples] = []
          s_sample_type.samples.each do |sa|
            tr[:samples] << (JSON.parse(sa.json_metadata)).select { |att| attributes.include?(att) }
          end
          item[:data] << tr
        end
        s.assays.each do |a|
          template = a.sample_type.repository_standard
          tr[:template] = template.title
          tr[:samples] = []
          if (template_ids.include?(template.id))
            attributes = template.template_attributes.pluck(:title)
            a.sample_type.samples.each do |sa|
              tr[:samples] << (JSON.parse(sa.json_metadata)).select { |att| attributes.include?(att) }
            end
          else
          end
          item[:data] << tr
        end
      end
      arr << item
    end

    puts "======================="
    puts "project_ids", arr.inspect

    # @arr = []
    # Project.where(id: project_ids).each do |p|
    #   item = {}
    #   item["project_id"] = p.id
    #   item["samples"] = []
    #   p.sample_types.where(repository_standard_id: template_ids).each do |s|
    #     item["repository_standard_id"] = s.repository_standard_id
    #     item["samples"].push(s.samples.map {|sa| {
    #       :id => sa.id, 
    #       :json_metadata => JSON.parse(sa.json_metadata), 
    #       :link_id => sa.link_id}}) if s.samples.any?
    #   end
    #   @arr.push(item)
    # end

    # result = {:header=>[], :items=>arr}

    # RepositoryStandard.where(id: template_ids).sample_types.each do |s|
    #   s.samples
    # end

    






  
    # arr = []
    # RepositoryStandard.where(id: template_ids).each do |t|
    #   attributes = t.template_attributes.pluck(:title)
    #   item = {:template => t.title, :projects=>[]} 
    #   t.sample_types.each do |s|
    #     s.projects.order(:id).each do |p|
    #       pr = {:pid => p.id, :samples => []}
    #       s.samples.each do |sa|
    #         pr[:samples].push((JSON.parse(sa.json_metadata)).select { |a| attributes.include?(a) })
    #       end
    #       item[:projects] << pr
    #     end
    #   end
    #   arr << item
    #   # (arr ||= []) << item
    # end
    # puts "======================="
    # puts "project_ids", arr.inspect











  
    # data.map(&:values).select { |state, values| values["name"] == ?A }

   

    # hash = []
    # template_ids.each do |id|
    #   puts "id::: ", id
    #   item = {}
    #   rs = RepositoryStandard.find(id)
    #   item["attributes"] = rs.template_attributes.pluck(:title)
    #   rs.sample_types.each do |sample_type|
    #     item["project_id"] = sample_type.project.id
    #     item["samples"] = sample_type.samples
    #   end
    #   hash.push(item)
    # end
    # puts "======================="
    # puts hash


    respond_to do |format|
      format.html { render action: 'index' }
    end
  end

  private

  def init
    @templates = RepositoryStandard.all
  end

  def template_report_params
    params.permit( template_ids: [])
  end


end
