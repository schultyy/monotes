require 'monotes/app_directory'

module Monotes
  module IO
    class FSDelegate
      include Monotes::AppDirectory

      #
      # issues: Issues represented as Hash
      #
      def save(username, repository, issues)
        if !File.directory?(app_path)
          Dir.mkdir(app_path)
        end
        user_folder = File.join(app_path, username)
        Dir.mkdir(user_folder) if !File.directory?(user_folder)
        File.open(File.join(user_folder, "#{repository}.yaml"), "w") do |handle|
          handle.write(issues.to_yaml)
        end
      end

      def load(username, repository)
        abs_path = File.join(app_path, username, "#{repository}.yaml")
        YAML.load_file(abs_path)
      rescue Errno::ENOENT
        []
      end
    end
  end
end
