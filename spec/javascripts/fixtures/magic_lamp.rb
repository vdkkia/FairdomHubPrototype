# # Broken fixture
# MagicLamp.register_fixture(controller: SopsController, name: 'sops/with_associations') do
#   assay = Factory(:assay, :policy => Factory(:public_policy))
#   @sop = Factory(:sop,
#                  :assays => [assay],
#                  :policy => Factory(:public_policy))
#   @sop.valid?
#   @display_sop = @sop.latest_version
#   render :show
# end

# MagicLamp.register_fixture(controller: SopsController, name: 'sops/new') do
#   @controller_name = 'sops'
#   @sop = Sop.new
#   # Set the current_user
#   User.current_user = Factory(:user)
#   session[:user_id] = User.current_user.id.to_s
#   # Some URL helpers in the template don't work without this:
#   request.env["action_dispatch.request.path_parameters"] = {
#       action: "new",
#       controller: "sops",
#   }
#   render :new
# end

# MagicLamp.register_fixture(controller: SopsController, name: 'sops/manage') do
#   @sop = Factory(:sop, policy: Factory(:public_policy))
#   @sop.valid?
#   @display_sop = @sop.latest_version
#   User.current_user = @sop.contributor.user
#   session[:user_id] = User.current_user.id.to_s
#   request.env["action_dispatch.request.path_parameters"] = {
#       action: "manage",
#       controller: "sops",
#       id: @sop.id
#   }
#   render :manage
# end

# MagicLamp.register_fixture(name: 'sharing/form') do
#   @sop = Factory(:sop, policy: Factory(:public_policy))
#   @sop.valid?
#   @display_sop = @sop.latest_version
#   User.current_user = @sop.contributor.user
#   session[:user_id] = User.current_user.id.to_s
#   request.env["action_dispatch.request.path_parameters"] = {
#       action: "edit",
#       controller: "sops",
#       id: @sop.id
#   }
#   render partial: 'sharing/form', locals: { object: @sop }
# end


# MagicLamp.register_fixture(name: 'projects-selector') do
#   @sop = Factory(:sop, policy: Factory(:public_policy))
#   @sop.valid?
#   @display_sop = @sop.latest_version
#   User.current_user = @sop.contributor.user
#   session[:user_id] = User.current_user.id.to_s
#   request.env["action_dispatch.request.path_parameters"] = {
#       action: "edit",
#       controller: "sops",
#       id: @sop.id
#   }
#   render partial: 'projects/project_selector', locals: { resource: @sop }
# end

# MagicLamp.register_fixture(name: 'project/markdown') do
#   User.current_user = Factory(:user)
#   session[:user_id] = User.current_user.id.to_s

#   @project = Project.create(title: 'markdown test',
#     description: '# header

# Some text

# ## second header

# _italic **bold** text_

# > Another paragraph')
#   render "projects/show"
# end

MagicLamp.register_fixture(controller: SinglePagesController, name:'single_pages') do
  User.current_user = Factory(:user)
  session[:user_id] = User.current_user.id.to_s
  person = User.current_user.person
  @project = Factory(:project)
  
  @investigation = Factory(:investigation, project_ids: [@project.id])
  @study = Factory(:study, investigation: @investigation)
  source_sample_type = Factory(:simple_sample_type)
  assay = Factory(:assay, contributor: person, study: @study)
  flowchart = Factory(:min_flowchart, study_id: @study.id, source_sample_type_id: source_sample_type.id)

  request.env["action_dispatch.request.path_parameters"] = {
      action: "show",
      controller: "single_pages",
      id: @project.id
  }
  render :show
end