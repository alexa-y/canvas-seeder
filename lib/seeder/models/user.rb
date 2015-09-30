module Seeder::Models
  class User
    attr_accessor :id, :account_id, :name, :email, :username, :password, :sis_id

    def initialize(account_id)
      self.account_id = account_id
    end

    def populate
      self.name = Forgery::Name.full_name
      self.email = Forgery::Email.address
      user_number = SecureRandom.random_number(1000)
      self.username = "#{Forgery::Internet.user_name}_#{user_number}"
      self.password = SecureRandom.hex
      self.sis_id = "sis_#{username}_#{user_number}"
    end

    def save!(client)
      resp = client.add_user(account_id, { user: { name: name, skip_registration: true }, pseudonym: { unique_id:
        username, password: password, send_confirmation: false, sis_user_id: sis_id }, communication_channel: { type: 'email', address: email } })
      self.id = resp['id']
      Rails.logger.info("Created user #{username}")
    end
  end
end
