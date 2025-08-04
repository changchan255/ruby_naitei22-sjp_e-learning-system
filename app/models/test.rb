class Test < ApplicationRecord
  has_many :questions, dependent: :destroy
  # Một bài test có thể được sử dụng trong nhiều component
  has_many :components
end
