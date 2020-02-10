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
ends



#Problem 5
1) I will initially Requirement analysis
2) If needed then i will create a table in database, here i will check can i use relational database or non-relational database. If its bulk upload then i will go with non-relational database or else no.
3) Then i will follow the MVC Architecture,  i will create API and try to get the json result. Then i will show at UI
4) As per the UI libraries i will go with Angular or React why because these are very powerful Javascript frameworkd
5) If we wants to develop the Application very fast then i will chose RoR langugae at server side, why because it have very beatiful concept i.e conventional over configuration



