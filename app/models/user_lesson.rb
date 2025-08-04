class UserLesson < ApplicationRecord
  belongs_to :user
  belongs_to :lesson

  enum status: { todo: 0, doing: 1, pass: 2, fail: 3 }
end
