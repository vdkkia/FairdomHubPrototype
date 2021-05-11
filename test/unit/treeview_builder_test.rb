require "test_helper"

class TreeviewBuilderTest < ActionController::TestCase
  fixtures :all
  include AuthenticatedTestHelper

  test "create node" do
    p = Factory(:project)
    f = Factory :project_folder, project_id: p.id
    node_text = "test node text"
    node_type = "prj"
    node_count = "7"
    node_id = "10"
    node_style = "font-weight:bold"
    node_label = "test label"
    node_action = "#"
    node_state_opened = true

    controller = TreeviewBuilder.new p, f
    assert_equal controller.send(:create_node, {text: node_text, _type: node_type, count: node_count,
        _id: node_id, a_attr: { style: node_style }, opened: node_state_opened, label: node_label, action: node_action}),
        text: node_text, a_attr: {style: node_style}, count: node_count, data: {id: node_id, type: node_type,
             project_id: nil, folder_id: nil}, state: {opened: true, separate: {label: node_label, action: node_action}},
              icon: "/avatars/avatar-prj.png"
  end

  test "remove empty keys when create node" do
    p = Factory(:project)
    f = Factory :project_folder, project_id: p.id

    node_text = "test node text"
    node_type = "prj"
    controller = TreeviewBuilder.new p, f
    assert_equal controller.send(:create_node, {text: node_text, _type: node_type}),
     text: node_text, data:{id:nil, type: node_type, project_id:nil, folder_id:nil},
      state:{opened:true}, icon:"/avatars/avatar-prj.png"
  end

  test "build tree data with default root folder" do
    p = Factory(:project)
    f = Factory :project_folder, project_id: p.id
    i = Factory(:investigation, projects: [p])
    s = Factory(:study, investigation: i)
    a = Factory(:assay, study: s)
    controller = TreeviewBuilder.new p, f
    result = controller.send(:build_tree_data)
    assert_instance_of Array, JSON.parse(result)
  end

  test "build tree data with folders" do
    p = Factory(:project)
    f = Factory :project_folder, project_id: p.id
    sop = Factory :sop, project_ids: [p.id], policy: Factory(:public_policy)
    f.add_assets(sop)
    f.save!

    i = Factory(:investigation, projects: [p])
    s = Factory(:study, investigation: i)
    a = Factory(:assay, study: s)

    controller = TreeviewBuilder.new p, f
    result = controller.send(:build_tree_data)
    assert_instance_of Array, JSON.parse(result)
  end

  test "return tree data of minimal project" do
    project = Factory(:project)
    folders = Factory :project_folder, project_id: project.id
    investigation = Factory(:investigation, projects: [project])
    study = Factory(:study, investigation: investigation)
    source_sample_type = Factory(:min_sample_type)
    
    assay1 = Factory(:assay, title: "assay1", study: study)
    sample_type_1 = Factory(:min_sample_type, assays: [assay1])
    assay2 = Factory(:assay, title: "assay2", study: study)
    sample_type_2 = Factory(:min_sample_type, assays: [assay2])

    flowchart = Flowchart.create({study_id: study.id, source_sample_type_id: source_sample_type})
    stream = Stream.create({title: "test stream", flowchart_id: flowchart.id})
    stream_item_1 = StreamItem.create({stream_id: stream.id, sample_type_id: source_sample_type.id})
    stream_item_2 = StreamItem.create({stream_id: stream.id, sample_type_id: sample_type_1.id})
    stream_item_3 = StreamItem.create({stream_id: stream.id, sample_type_id: sample_type_2.id})

    controller = TreeviewBuilder.new project, folders
    result = JSON.parse controller.send(:build_tree_data)

    tree_investigation = result[0]["children"]
    assert_equal tree_investigation.length, 1

    tree_study = tree_investigation[0]["children"]
    assert_equal tree_study.length, 1

    tree_stream = tree_study[0]["children"][0]
    assert_equal tree_stream["text"], "test stream"
    assert_equal tree_stream["children"].length, 2
    assert_equal tree_stream["children"][0]["text"], "assay1"
    assert_equal tree_stream["children"][1]["text"], "assay2"

  end

end
