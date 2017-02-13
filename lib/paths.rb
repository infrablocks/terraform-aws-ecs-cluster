module Paths
  class <<self
    def project_root_directory
      join_and_expand(self_directory, '..')
    end

    def from_project_root_directory *segments
      join_and_expand(project_root_directory, *segments)
    end

    private

    def join_and_expand *segments
      File.expand_path(File.join(*segments.compact))
    end

    def self_directory
      File.dirname(__FILE__)
    end
  end
end
