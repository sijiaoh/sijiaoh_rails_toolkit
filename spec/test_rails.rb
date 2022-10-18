require "fileutils"

# Create rails project under tmp directory.
class TestRails
  RAILS_DIR = "tmp/test_rails".freeze

  def create!
    assert_directory_not_exist

    create_directory
    copy_dotbundle_to_directory

    rails_new
  end

  def destroy
    FileUtils.rm_rf RAILS_DIR
  end

  def system!(command)
    system command, chdir: RAILS_DIR, exception: true
  end

  private

  def assert_directory_not_exist
    raise "Directory #{RAILS_DIR} already exists" if File.exist? RAILS_DIR
  end

  def create_directory
    FileUtils.mkdir_p RAILS_DIR
  end

  def copy_dotbundle_to_directory
    FileUtils.cp_r ".bundle", RAILS_DIR
  end

  def rails_new
    system! "yes | bundle exec rails new ."
  end
end
