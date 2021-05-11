require 'test_helper'

class SinglePageFlowchartTest < ActionDispatch::IntegrationTest

  include HtmlHelper

  def setup
    User.current_user = Factory(:user, login: 'test')
    @current_user = User.current_user
    post '/session', params: { login: 'test', password: generate_user_password }
    @project = Factory(:project)
    @investigation = Factory(:investigation, project_ids: [@project.id])
    @study = Factory(:study, investigation: @investigation)
    source_sample_type = Factory(:simple_sample_type)
    assay = Factory(:assay, contributor: @current_user.person, study: @study)
    flowchart = Factory(:min_flowchart, study_id: @study.id, source_sample_type_id: source_sample_type.id)
  end

  test 'show single_page' do
    get "single_pages/#{@project.id}"
    assert_response :success
  end

  

end
