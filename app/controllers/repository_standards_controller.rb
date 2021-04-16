class RepositoryStandardsController < ApplicationController
  respond_to :html
  include Seek::IndexPager
  before_action :find_repository_standard, only: [:show]
  before_action :find_assets, only: [:index]

  def show
    respond_to do |format|
      format.html
    end
  end

  def new
    @tab = 'manual'
    @repository_standard = RepositoryStandard.new
    respond_with(@repository_standard)
  end

  def create
    @repository_standard = RepositoryStandard.new(repository_standard_params)
    @repository_standard.contributor = User.current_user.person
    @tab = 'manual'

    respond_to do |format|
      if @repository_standard.save
        format.html { redirect_to @repository_standard, notice: 'Repository standard was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def destroy
    respond_to do |format|
    if @repository_standard.can_delete? && @repository_standard.destroy
      format.html { redirect_to @repository_standard,location: repository_standards_path, notice: 'Repository standard was successfully deleted.' }
    else
      format.html { redirect_to @repository_standard, location: repository_standards_path, notice: 'It was not possible to delete the repository standard.' }
    end
    end
  end

  private

  def repository_standard_params
    params.require(:repository_standard).permit(:title, :description, :tags, :repository_standard_id,
                                        { project_ids: [],
                                          template_attributes_attributes: [:id, :title, :required,
                                                                        :sample_attribute_type_id, :isa_tag_id,
                                                                        :sample_controlled_vocab_id,
                                                                        :unit_id, :_destroy]})
  end

  def find_repository_standard
    @repository_standard = RepositoryStandard.find(params[:id])
  end
end
