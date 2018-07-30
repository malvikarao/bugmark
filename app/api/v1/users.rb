module V1
  class Users < V1::App

    resource :users do

      # ---------- list all user ids ----------
      desc "List all user ids", {
        is_array: true ,
        success:  Entities::UserIds
      }
      params do
        optional :with_email, type: String, desc: "email filter"
      end
      get do
        email = params[:with_email]
        scope = User.all
        scope = scope.where("email like ?", "%#{email}%") if email
        present(scope, with: Entities::UserIds)
      end

      # ---------- list all user details ----------
      desc "List all user details", {
        is_array: true ,
        success:  Entities::UserDetail
      }
      params do
        optional :with_email, type: String, desc: "email filter"
      end
      get '/detail' do
        email = params[:with_email]
        scope = User.all
        scope = scope.where("email like ?", "%#{email}%") if email
        present(scope, with: Entities::UserDetail)
      end

      # ---------- show user detail ----------
      desc "Show details for one user", {
        success: Entities::UserDetail
      }
      params do
        requires :uuid     , type: String , desc: "user uuid"
        optional :offers   , type: Boolean, desc: "include open offers"
        optional :positions, type: Boolean, desc: "include open positions"
      end
      get ':uuid' do
        if user = User.find_by_uuid(params[:uuid])
          opts = {
            with:      Entities::UserDetail      ,
            offers:    params[:offers].to_s      ,
            positions: params[:positions].to_s   ,
          }
          present(user, opts)
        else
          error!("not found", 404)
        end
      end

      # ---------- create a user ----------
      # TODO: return error code for duplicate user
      desc "Create a user", {
        success:  Entities::UserIds        ,
        consumes: ['multipart/form-data']  ,
        detail: <<-EOF.strip_heredoc
          Create a user.  Supply an optional opening balance.  (Default 0.0)
        EOF
      }
      params do
        requires :usermail , type: String , desc: "user email"
        requires :password , type: String , desc: "user password"
        optional :balance  , type: Float  , desc: "opening balance"
      end
      post do
        opts = { email: params[:usermail], password: params[:password] }
        opts[:balance] = params[:balance] if params[:balance]
        command = UserCmd::Create.new(opts)
        if command.valid?
          command.project
          present(command.user, with: Entities::UserOverview)
        else
          {status: "error", message: command.errors.messages.to_s}
        end
      end

      # ---------- deposit funds ----------
      desc "Deposit funds", {
        success:  Entities::Status            ,
        consumes: ['multipart/form-data']
      }
      params do
        requires :amount , type: Float
      end
      put ':uuid/deposit' do
        user = User.find_by_uuid(params[:uuid])
        args = {uuid: params[:uuid], amount: params[:amount] }
        cmd  = UserCmd::Deposit.new(args)
        if user && cmd.valid?
          cmd.project
          {status: "OK"}
        else
          {status: "error"}
        end
      end

      # ---------- withdraw funds ----------
      desc "Withdraw funds", {
        success:  Entities::Status            ,
        consumes: ['multipart/form-data']
      }
      params do
        requires :amount , type: Float
      end
      put ':uuid/withdraw' do
        user = User.find_by_uuid(params[:uuid])
        args = {uuid: params[:uuid], amount: params[:amount] }
        cmd  = UserCmd::Withdraw.new(args)
        if user && cmd.valid?
          cmd.project
          {status: "OK"}
        else
          {status: "Error"}
        end
      end
    end
  end
end
