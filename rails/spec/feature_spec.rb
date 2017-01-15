feature 'User apply for credit cards', type: :feature do

  before(:all) do 
    create_list(:credit_cards, 3)
  end

  context 'select no cards' do
    before(:each) do
      visit credit_cards_path
    end

    scenario 'shows alert message on proceed' do
      page.accept_alert 'Please select any card' do
        click_button('Proceed')
      end
    end
  end
  
  context 'select card' do
    before(:each) do
      visit credit_cards_path
    end

    scenario 'redirects to apply page' do
      first(:css, '.package').click
      click_button('Proceed')
      expect(page).to have_current_path(apply_credit_cards_path)
    end
  end
  
  context 'provides invalid info' do  
    scenario 'shows validation errors' do
      first(:css, '.package').click
      click_button('Proceed')
      expect(page).to have_current_path(apply_credit_cards_path) 
      fill_in('application_full_name', with: 'Sunil Antony')
      click_button('Apply')
      expect(page).to have_current_path(apply_credit_cards_path)
      expect(page).to have_css('span.errors')
    end
  end
  
  context 'provides valid info' do      
    scenario 'redirects to thank you page' do
      first(:css, '.package').click
      click_button('Proceed')
      expect(page).to have_current_path(apply_credit_cards_path) 
      fill_in('application_full_name', with: 'Sunil Antony')
      fill_in('application_email', with: 'sunil@gmail.com')
      fill_in('application_phone_number', with: '+6017341423')
      fill_in('application_monthly_income', with: '5000')
      fill_in('application_age', with: '30')
      click_button('Apply')
      expect(page).to have_current_path(thank_you_loans_path)
    end
  end
end


  