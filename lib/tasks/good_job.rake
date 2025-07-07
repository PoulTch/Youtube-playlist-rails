namespace :good_job do
  desc "Starts a GoodJob worker"
  task start: :environment do
    puts "Starting GoodJob worker via Rake task..."
    GoodJob.run_as_executable
  end
end