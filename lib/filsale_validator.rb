module FilsaleValidator
  class EmailUniqueInFilsaleValidator < ActiveModel::EachValidator

    def validate_each(record, attr, value)
      return unless record.errors[:email].empty?
      record.errors.add(attr, msg, options) unless email_valid?(record, value)
    end

    private

      def msg; 'is already taken'; end

      def email_valid?( record, value )
        user = nil
        [Admin, Merchant, User].each do |model|
          user = model.where(:email => value)
          break unless user.empty?
        end
        user.empty? || user.first.id == record.id
      end
  end
end
