class Bug < ApplicationRecord

  has_paper_trail

  belongs_to      :repo,      :foreign_key => :stm_repo_id
  has_many        :contracts, :dependent   => :destroy
  has_many        :bids
  has_many        :asks

  hstore_accessor :xfields  , :html_url  => :string    # add field to hstore

  def xtag
    "bug"
  end

  def xtype
    self.type.gsub("Bug::","")
  end

  # ----- SCOPES -----

  class << self

    def base_scope
      where(false)
    end

    def by_id(id)
      where(id: id)
    end

    def by_repoid(id)
      where(stm_repo_id: id)
    end

    def by_title(string)
      where("title ilike ?", string)
    end

    def by_status(status)
      where("stm_status ilike ?", status)
    end

    def by_labels(labels)
      # where(labels: labels)
      where(false)
    end

    # -----

    def match(attrs)
      attrs.without_blanks.reduce(base_scope) do |acc, (key, val)|
        scope_for(acc, key, val)
      end
    end

    private

    def scope_for(base, key, val)
      case key
        when :id then
          base.by_id(val)
        when :stm_repo_id then
          base.by_repoid(val)
        when :stm_title then
          base.by_title(val)
        when :stm_status then
          base.by_status(val)
        when :stm_labels then
          base.by_labels(val)
        else base
      end
    end

  end
end

# == Schema Information
#
# Table name: bugs
#
#  id          :integer          not null, primary key
#  type        :string
#  xfields     :hstore           not null
#  jfields     :jsonb            not null
#  synced_at   :datetime
#  exref       :string
#  uuref       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  stm_repo_id :integer
#  stm_bug_id  :integer
#  stm_title   :string
#  stm_status  :string
#  stm_labels  :string
#  stm_xfields :hstore           not null
#  stm_jfields :jsonb            not null
#
