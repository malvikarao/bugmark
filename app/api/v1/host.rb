module V1
  class Host < V1::App

    resource :host do

      # ---------- show host info ----------
      desc "get host info", {
        success: Entities::HostInfo                ,
        detail: <<-EOF.strip_heredoc
          Show host info: host-time, day offset, datastore type, etc.
        EOF
      }
      params do
        optional :strftime, type: String, desc: "STRFTIME string for host_time"
      end
      get "/info" do
        host_time = BugmTime.now.strftime(params[:strftime] || "%Y-%m-%d_%H:%M")
        data = {
          host_name:   BugmHost.name        ,
          host_time:   host_time            ,
          day_offset:  BugmTime.day_offset  ,
          hour_offset: BugmTime.hour_offset ,
          datastore:   BugmHost.datastore   ,
          released_at: BugmTime.released_at ,
          usermail:    current_user&.email  ,
          useruuid:    current_user&.uuid
        }
        present(data, with: Entities::HostInfo)
      end

      # ---------- ping: get heartbeat ----------
      desc "check server access", {
        success: Entities::Status
      }
      get "/ping" do
        {status: "OK"}
      end

      # ---------- list host counts ----------
      desc "counts", {
        success: Entities::HostCount                   ,
        detail: <<-EOF.strip_heredoc
          Show host object counts: number of users, offers, contracts, etc.
        EOF
      }
      get "/counts" do
        DatapointCmd::Base.new.project      # record metrics...
        {
          host_name:      BugmHost.name                      ,
          users:          User.count                         ,
          trackers:          Tracker.count                         ,
          issues:         Issue.count                        ,
          offers:         Offer.count                        ,
          offers_open:    Offer.open.count                   ,
          offers_open_bu: Offer::Buy::Unfixed.open.count     ,
          offers_open_bf: Offer::Buy::Fixed.open.count       ,
          contracts:      Contract.count                     ,
          contracts_open: Contract.open.count                ,
          positions:      Position.count                     ,
          amendments:     Amendment.count                    ,
          escrows:        Escrow.count                       ,
          events:         Event.count
        }
      end

      # ---------- next week-ends ----------
      desc "next week-ends", {
        success:  Entities::NextWeekEnds
      }
      params do
        optional :count, type: Integer, desc: "count (default 4)"
      end
      get "/next_week_ends" do
        list = BugmTime.next_week_ends(params[:count] || 4)
        present({next_week_ends: list}, with: Entities::NextWeekEnds)
      end

      # ---------- increment day offset ----------
      desc "increment day offset", {
        success:  Entities::Status     ,
        consumes: ['multipart/form-data']
      }
      params do
        optional :count, type: Integer, desc: "count (default 1)"
      end
      put "/increment_day_offset" do
        error!("Permanent Datastore", 403) if BugmHost.datastore != 'mutable'
        BugmTime.increment_day_offset(params[:count] || 1)
        {status: "OK"}
      end

      # ---------- increment hour offset ----------
      desc "increment hour offset", {
        success:  Entities::Status     ,
        consumes: ['multipart/form-data']
      }
      params do
        optional :count, type: Integer, desc: "count (default 1)"
      end
      put "/increment_hour_offset" do
        error!("Permanent Datastore", 403) if BugmHost.datastore != 'mutable'
        BugmTime.increment_hour_offset(params[:count] || 1)
        {status: "OK"}
      end

      # ---------- go past end_of_day ----------
      desc "go past end-of-day", {
        success:  Entities::Status     ,
        consumes: ['multipart/form-data']
      }
      params do
        optional :count, type: Integer, desc: "count (default 1)"
      end
      put "/go_past_end_of_day" do
        error!("Permanent Datastore", 403) if BugmHost.datastore != 'mutable'
        BugmTime.go_past_end_of_day(params[:count] || 1)
        {status: "OK"}
      end

      # ---------- go past end_of_week ----------
      desc "go past end-of-week", {
        success:  Entities::Status     ,
        consumes: ['multipart/form-data']
      }
      params do
        optional :count, type: Integer, desc: "count (default 1)"
      end
      put "/go_past_end_of_week" do
        error!("Permanent Datastore", 403) if BugmHost.datastore != 'mutable'
        BugmTime.go_past_end_of_week(params[:count] || 1)
        {status: "OK"}
      end

      # ---------- go past end_of_month ----------
      desc "go past end-of-month", {
        success:  Entities::Status     ,
        consumes: ['multipart/form-data']
      }
      params do
        optional :count, type: Integer, desc: "count (default 1)"
      end
      put "/go_past_end_of_month" do
        error!("Permanent Datastore", 403) if BugmHost.datastore != 'mutable'
        BugmTime.go_past_end_of_month(params[:count] || 1)
        {status: "OK"}
      end

      # ---------- set current time ----------
      desc "set current time", {
        success:  Entities::Status
      }
      put "/set_current_time" do
        error!("Permanent Datastore", 403) if BugmHost.datastore != 'mutable'
        BugmTime.clear_offset if BugmTime.total_hour_offset < 0
        {status: "OK"}
      end

      # ---------- rebuild the system----------
      desc "rebuild", {
        success:  Entities::Status                               ,
        failure:  [[403, "Can't Rebuild Permanent Datastore"]]   ,
        consumes: ['multipart/form-data']                        ,
        detail: <<~EOF
          Destroy all data and rebuild the system. The rebuilt system 
          will have one user: `user/pass` = `admin@bugmark.net/bugmark`.

          To run this command, you must post a confirmation parameter:

          `/host/rebuild?confirm=destroy_all_data`

          Optionally, you can use the 'with_day_offset' param to set the start 
          date for your system.  This can be used for simulations where you
          want to use historical data:

          `host/rebuild?confirm=destroy_all_data&with_day_offset=-90`

          The rebuild command is intended for use on hosts dedicated for 
          research and testing. (and not production!)  The rebuild command will
          work for hosts with `mutable` datastores, and will fail for hosts
          with `permanent` datastores.

          View the datastore setting with the `/hosts/info` command.
        EOF
      }
      params do
        requires :affirm         , type: String , desc: "confirmation", values: ["destroy_all_data"]
        optional :with_day_offset, type: Integer, desc: "initial day offset"
      end
      post "/rebuild" do
        error!("Permanent Datastore", 403) if BugmHost.datastore != 'mutable'
        BugmHost.reset
        offset = params[:with_day_offset]
        BugmTime.set_day_offset(offset) if offset
        {status: "OK", message: "all data destroyed - login with admin@bugmark.net"}
      end
    end
  end
end
