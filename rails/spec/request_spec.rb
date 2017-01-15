describe 'Rating API', type: :request do

	before(:each) do
    @user = create(:user)
  end
   
  it 'adds rating to an establishment' do
    establishment = create(:establishment, rating: 0.0) 
    post '/api/v1/ratings', params: {establishment_id: establishment.id, 
       rating: {food: 3, crowd: 4, music: 5, review: 'sample review'}}, 
       headers: {'Authorization' => @user.auth_token} 
    expect(response).to be_success
    expect(establishment.ratings.count).to eq 1
    expect(establishment.reload.rating).to eq 4
  end

  it 'updates rating' do
    establishment = create(:establishment, rating: 0.0) 
    rating = create(:rating, crowd: 2, music: 2, establishment: establishment, user: @user)
    patch "/api/v1/ratings/#{rating.id}", params: {rating: {food: 3, crowd: 4, 
      music: 5, review: 'updated review'}}, 
      headers: {'Authorization' => @user.auth_token} 
    expect(response).to be_success
    expect(establishment.ratings.count).to eq 1
    expect(rating.reload.review).to eq 'updated review'
    expect(establishment.reload.rating).to eq 4
  end

  it 'makes rating commenatable' do
    rating = create(:rating)
    post  "/api/v1/ratings/#{rating.id}/comment", params: {comment: 'sample comment'}, 
      headers: {'Authorization' => @user.auth_token} 
    expect(response).to be_success
    expect(rating.reload.comments.count).to eq 1
  end

  it 'makes rating likeable and unlikeable' do
    rating = create(:rating)
    activity = create(:activity, subject: rating)
    post "/api/v1/ratings/#{rating.id}/like", headers: {'Authorization' => @user.auth_token} 
    expect(response).to be_success
    expect(activity.reload.likes_count).to eq 1
    post  "/api/v1/ratings/#{rating.id}/like", headers: {'Authorization' => @user.auth_token} 
    expect(activity.reload.likes_count).to eq 0
  end

  it 'provides rating details' do
    user2 = create(:user)
    establishment = create(:establishment, rating: 0.0) 
    rating = create(:rating, establishment: establishment, user: @user)
    activity = create(:activity, subject: rating)
    create(:comment, rating: rating, user: user2)
    get_url "/ratings/#{rating.id}", headers: {'Authorization' => @user.auth_token} 
    expect(response).to be_success
    attributes = %w(total_rating updated_at review like_count comments_count has_liked)
    expect(data['attributes']).to include(*attributes)
    included_attributes = %w(users establishments comments)
    expect(included.map(&:values).flatten).to include(*included_attributes)    
  end

end	