class IssueQuery
  include ActiveModel::Model

  attr_accessor :free_qry, :lang_qry, :offer_qry

  def search
    if free_qry.blank? && lang_qry.blank?
      Issue.all
    else
      qscore(free_qry, lang_qry)
    end
  end

  private

  def qscore(freq, lanq)
    qs = []
    qs << rank_str("'uuid'||bugs.uuid"         , freq) if freq.present?
    qs << rank_str("'tracker'||stm_tracker_uuid"     , freq) if freq.present?
    qs << rank_str("stm_title"                 , freq) if freq.present?
    qs << rank_str("stm_labels"                , freq) if freq.present?
    qs << rank_str("stm_jfields->'comments'"   , freq) if freq.present?
    qs << rank_str("trackers.xfields->'languages'", lanq) if lanq.present?
    rank = qs.join(" + ")
    Issue.joins(:tracker).where("#{rank} > 0").order("#{rank} desc")
  end

  def rank_str(field, qry)
    "ts_rank(to_tsvector('english', #{field}),  plainto_tsquery('english', '#{qry}'))"
  end
end
