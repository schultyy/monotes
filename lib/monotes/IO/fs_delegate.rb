require 'monotes/app_directory'

module Monotes
  module IO
    class FSDelegate
      include Monotes::AppDirectory

      def write(filename, content)
        File.open(File.join(app_path, filename), 'w') do |handle|
          handle.write(content)
        end
      end
    end
  end
end
