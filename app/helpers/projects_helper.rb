# frozen_string_literal: true

module ProjectsHelper
  def project_channel_id(project)
    dom_id(project, :channel)
  end
end
