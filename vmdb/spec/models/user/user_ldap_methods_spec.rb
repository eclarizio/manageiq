require "spec_helper"

describe User do
  context ".find_or_create_by_ldap_attr" do
    before do
      _guid, _server, _zone = EvmSpecHelper.create_guid_miq_server_zone
      @auth_config = {
        :authentication => {
          :mode        => "ldap",
          :ldap_role   => true,
          :user_suffix => "manageiq.org",
          :user_type   => "userprincipalname",
        }
      }
    end
    subject(:current_user) { described_class.find_or_create_by_ldap_attr(@user_type, @username) }

    it "with invalid attribute" do
      @user_type = "invalid"
      expect { current_user }.to raise_error
    end

    context "with userid" do
      before { @user_type = "ignored" }

      it "user exists" do
        user       = FactoryGirl.create(:user_admin, :userid => "testuser")
        @username  = user.userid

        expect(current_user).to eq(user)
      end
    end

    context "with userprincipalname" do
      before do
        @username    = "upnuser"
        @user_type   = @auth_config.fetch_path(:authentication, :user_type)
        @user_suffix = @auth_config.fetch_path(:authentication, :user_suffix)
        @fqusername  = "#{@username}@#{@user_suffix}"

        init_ldap_setup
        @miq_ldap.stub(:fqusername => @fqusername)
      end

      it "initial status" do
        expect(User.all.size).to eq(0)
      end

      it "user exists" do
        user = FactoryGirl.create(:user_admin, :userid => @fqusername)
        expect(current_user).to eq(user)
      end

      it "user does not exist" do
        group = create_super_admin_group
        setup_to_create_user(group)

        expect(current_user).to be_present
        expect(User.all.size).to eq(1)
      end
    end

    context "with mail" do
      before do
        @username    = "mailuser@bymail.com"
        @user_type   = "mail"
        init_ldap_setup
      end

      it "initial status" do
        expect(User.all.size).to eq(0)
      end

      it "user exists" do
        user = FactoryGirl.create(:user_admin, :userid => "mailuser", :email => @username)
        expect(current_user).to eq(user)
      end

      it "user does not exist" do
        group = create_super_admin_group
        setup_to_create_user(group)

        expect(current_user).to be_present
        expect(User.all.size).to eq(1)
      end
    end
  end

  def create_super_admin_group
    FactoryGirl.create(
      :miq_group,
      :description   => "EvmGroup-super_administrator",
      :miq_user_role => FactoryGirl.create(:miq_user_role, :name => "EvmRole-super_administrator")
    )
  end

  def init_ldap_setup
    @miq_ldap = double('miq_ldap')
    @miq_ldap.stub(:bind => true)
    MiqLdap.stub(:new).and_return(@miq_ldap)
  end

  def setup_to_create_user(group)
    vmdb_config = double("vmdb_config")
    vmdb_config.stub(:config => @auth_config)
    VMDB::Config.stub(:new).with("vmdb").and_return(vmdb_config)

    @miq_ldap.stub(:get_user_object => "A Net::LDAP::Entry object")
    @miq_ldap.stub(:normalize => "some unique string")
    @miq_ldap.stub(:get_attr => "xx@xx.com")
    User.stub(:getUserMembership => [group.description])
  end
end
