namespace :test_cron do
  desc "checking tasks scheduling"
  task :check_task => :environment do
    puts "Inside task now #{Time.now}"
    SapExport.clear_init_create_test
  end
end
