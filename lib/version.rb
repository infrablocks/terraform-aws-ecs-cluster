module Semantic
  class Version
    def rc!
      new_version = clone

      if new_version.pre.nil?
        new_version.increment!(:minor)
        new_version.pre = 'rc.1'
        return new_version
      end

      if new_version.pre =~ /^rc\.\d+$/
        new_version.pre = "rc.#{Integer(new_version.pre.delete('rc.')) + 1}"
        return new_version
      end

      raise RuntimeError.new(
          "Error: pre segment '#{new_version.pre}' is does not look like 'rc.n'")
    end
  end
end
