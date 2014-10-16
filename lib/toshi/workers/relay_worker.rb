require "sidekiq"

module Toshi
  module Workers
    class RelayWorker
      include Sidekiq::Worker

      sidekiq_options queue: :relay, :retry => true

      def perform(type, hsh)
        if type == 'tx'
          peer_msg, client_msg = 'relay_tx', 'new_transaction'
        else
          peer_msg, client_msg = 'relay_block', 'new_block'
        end

        # this is for peers
        mq.workers_push_all({ 'msg' => peer_msg, 'hash' => hsh })

        # this is for websocket consumers
        mq.clients_push_all({ 'msg' => client_msg, 'hash' => hsh })
      end

      def mq
        @@mq ||= RedisMQ::Channel.new(:worker)
      end
    end
  end
end
