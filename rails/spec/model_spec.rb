describe User, type: :model do

	it { should respond_to(:auth_token) }
  it { should validate_uniqueness_of(:auth_token) }

  
  describe "#generate_auth_token!" do
    before { @user = build(:user) }
    it 'generates a unique token' do
    	Devise.stub(:friendly_token).and_return('auniquetoken123')
      @user.generate_authentication_token!
      expect(@user.auth_token).to eql 'auniquetoken123'
    end

    it 'generates another token when one already has been taken' do
      existing_user = create(:user, auth_token: 'auniquetoken123')
      @user.generate_authentication_token!
      expect(@user.auth_token).not_to eql existing_user.auth_token
    end
  end


  describe '.filter' do
    it 'is filtered by status' do
      create_list(:user, 3, status: 'active')
      create_list(:user, 2, status: 'new')
      result = User.filter {status: 'active'}
      expect(result.count).to eq 3
    end

    it 'is filtered by level' do
      create_list(:user, 3, level: 'junior')
      create_list(:user, 2, level: 'senior')
      result = User.filter {level: 'senior'}
      expect(result.count).to eq 2
    end
  end  

end