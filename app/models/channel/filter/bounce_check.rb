# Copyright (C) 2012-2014 Zammad Foundation, http://zammad-foundation.org/

module Channel::Filter::BounceCheck

  def self.run( _channel, mail )

    return if !mail[:mail_instance]
    return if !mail[:mail_instance].bounced?
    return if !mail[:attachments]
    return if mail[ 'x-zammad-ticket-id'.to_sym ]

    mail[:attachments].each {|attachment|
      next if !attachment[:preferences]
      next if attachment[:preferences]['Mime-Type'] != 'message/rfc822'
      next if !attachment[:data]
      result = Channel::EmailParser.new.parse(attachment[:data])
      next if !result[:message_id]
      message_id_md5 = Digest::MD5.hexdigest(result[:message_id])
      article = Ticket::Article.where(message_id_md5: message_id_md5).order('created_at DESC, id DESC').limit(1).first
      if article
        Rails.logger.debug "Follow up for '##{article.ticket.number}' in bounce email."
        mail[ 'x-zammad-ticket-id'.to_sym ] = article.ticket_id
        return true
      end
    }

  end
end
