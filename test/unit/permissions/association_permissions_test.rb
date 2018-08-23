require 'test_helper'

# Test that check that models cannot be interlinked where the permissions shouldn't allow
#
# ... for example it shouldn't be possible to link an Assay to a Study if the Study isn't visible and in the same project
class AssociationPermissionsTest < ActiveSupport::TestCase
  def setup
    @person = Factory(:person)
    @user = @person.user
    @project = @person.projects.first
    @another_person = Factory(:person_not_in_project)
    @another_person.add_to_project_and_institution(@project, @person.institutions.first)
  end

  # Assay->Study - study must be viewable and belong to the same project as the current user
  test 'assay linked to study' do
    User.with_current_user(@user) do
      investigation = Factory(:investigation, contributor: @person, projects:[@project])
      good_study = Factory(:study, contributor: @person, investigation: investigation)
      assay = Factory(:assay, contributor: @person, study: good_study)
      not_visible_study = Factory(:study, contributor: @another_person, investigation: investigation)
      not_in_project_study = Factory(:study, contributor: Factory(:person), policy: Factory(:public_policy))

      assert good_study.can_view?
      assert good_study.projects.include?(@project)

      refute not_visible_study.can_view?
      assert not_visible_study.projects.include?(@project)

      assert not_in_project_study.can_view?
      refute not_in_project_study.projects.include?(@project)

      assay.study = not_visible_study
      refute assay.save

      assay.study = not_in_project_study
      refute assay.save

      assay.study = good_study
      assert assay.save

      # check it saves with the study already linked
      assay = Factory(:assay, study: not_visible_study, contributor: @person, policy: Factory(:public_policy))
      assay.title='fish'
      assert assay.save
    end
  end

  # Study->Investigation investigation must be viewable and belong to the same project as the current user
  test 'study linked to investigation' do
    User.with_current_user(@user) do
      study = Factory(:study,contributor:@person)
      good_inv = Factory(:investigation, contributor:@person,projects:[@project])
      not_visible_inv = Factory(:investigation, contributor: @another_person, projects:[@project])
      not_in_project_inv = Factory(:investigation, contributor: Factory(:person),policy:Factory(:public_policy))

      assert good_inv.can_view?
      assert good_inv.projects.include?(@project)

      refute not_visible_inv.can_view?
      assert not_visible_inv.projects.include?(@project)

      assert not_in_project_inv.can_view?
      refute not_in_project_inv.projects.include?(@project)

      study.investigation = good_inv

      assert study.save

      study.investigation = not_visible_inv
      refute study.save

      study.investigation = not_in_project_inv
      refute study.save

      # check it saves with the study already linked
      study = Factory(:study,contributor:@person, investigation: not_visible_inv)
      study.title='fish'
      assert study.save
    end
  end

  # Asset->Assay - assay must be editable
  test 'assets linked to assay' do
    User.with_current_user(@user) do
      %i[data_file model sop sample document].each do |asset_type|
        good_assay = Factory(:assay,contributor:@person)
        not_editable_assay = Factory(:assay,policy:Factory(:publicly_viewable_policy))

        assert good_assay.can_edit?
        refute not_editable_assay.can_edit?
        assert not_editable_assay.can_view? #check is can actually be viewed

        asset = Factory(asset_type, contributor: @person)
        assert asset.can_edit?
        assert_empty asset.assays

        asset.assay_assets.create(assay: good_assay)
        assert asset.save
        asset.reload
        assert_equal [good_assay], asset.assays

        asset = Factory(asset_type, contributor: @person)
        assert asset.can_edit?
        assert_empty asset.assays

        asset.assay_assets.build(assay: not_editable_assay)
        refute asset.save
        asset.reload
        assert_empty asset.assays

        # check it only checks new links
        disable_authorization_checks do
          asset = Factory(asset_type, contributor: @person)
          asset.assay_assets.create(assay: not_editable_assay)
          assert asset.save
        end

        assert_equal [not_editable_assay], asset.assays
        asset.assay_assets.build(assay: good_assay)
        assert asset.save
        asset.reload
        assert_equal [good_assay, not_editable_assay].sort, asset.assays.sort
      end
    end
  end

  # Assay->Asset - asset must be viewable
  test 'assays linked to assets' do
    User.with_current_user(@user) do
      %i[data_file model sop sample document].each do |asset_type|
        good_asset = Factory(asset_type, policy: Factory(:publicly_viewable_policy), contributor: Factory(:person))
        bad_asset = Factory(asset_type, policy: Factory(:private_policy), contributor: Factory(:person))

        assert good_asset.can_view?
        refute bad_asset.can_view?

        assay = Factory(:assay, contributor: @person)
        assert assay.can_edit?

        assay.assay_assets.create(asset: good_asset)
        assert assay.save
        assay.reload
        assert_equal [good_asset], assay.assets

        assay.assay_assets.create(asset: bad_asset)
        refute assay.save
        assay.reload
        assert_equal [good_asset], assay.assets

        # check it only checks new links
        disable_authorization_checks do
          assay = Factory(:assay, contributor: @person)
          assay.assay_assets.create(asset: bad_asset)
          assert assay.save
        end

        assay.assay_assets.create(asset: good_asset)
        assert assay.save
        assay.reload
        assert_equal [good_asset, bad_asset].sort, assay.assets.sort
      end
    end
  end

  test 'must be in project when creating an asset' do
    good_results = []
    bad_results = []
    types = %i[investigation data_file model sop presentation sample document]
    User.with_current_user(@user) do
      other_project = Factory(:project)
      types.each do |asset_type|
        good_asset = Factory.build(asset_type, contributor: User.current_user.person, projects: [@project])
        bad_asset = Factory.build(asset_type, contributor: User.current_user.person, projects: [other_project])

        good_results << asset_type unless good_asset.save
        bad_results << asset_type if bad_asset.save
      end
    end

    assert_empty good_results,"#{good_results.join(', ')} failed so save with a valid project"
    assert_empty bad_results,"#{bad_results.join(', ')} successfully saved with a project the user isn't a member of"

  end

  test 'must be in project when creating an investigation' do
    User.with_current_user(@user) do
      other_project = Factory(:project)

      good_inv = Factory.build(:investigation, contributor: User.current_user.person, projects: [@project])
      bad_inv = Factory.build(:investigation, contributor: User.current_user.person, projects: [other_project])

      assert good_inv.save
      refute bad_inv.save
    end
  end
end
