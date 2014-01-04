FactoryGirl.define do
  factory :tweeter do
    sequence(:screen_name) { |n| "tweeter#{n}" }
  end
end
