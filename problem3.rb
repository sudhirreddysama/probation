class Application < ActiveRecord::Base
  belongs_to :applicant
  validates_presence_of :applicant
end

class Applicant < ActiveRecord::Base
  has_many :applications
  validates_presence_of :name
end

ActiveRecord::Base.transaction do
  app = Application.new
  app.build_applicant(name: "xyz")
  app.save
end