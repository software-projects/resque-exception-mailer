require 'net/smtp'

module Resque
  module Plugins
    module ExceptionMailer
      def self.defaults
        @defaults ||= {}.tap do |map|
          map[:host] = 'localhost'
          map[:port] = 25
          map[:helo] = 'localhost'
          map[:username] = nil
          map[:password] = nil
          map[:to] = nil
          map[:from] = 'resque-exception-mailer@example.org'
          map[:subject] = 'Resque: :job Failed - :type: :message'
          map[:body] = <<EOF
A Resque job failed to complete.

:type
:message


-------------------------------
Job:
-------------------------------

Type: :job
Args: :args
PID:  :pid


-------------------------------
Stacktrace:
-------------------------------

:backtrace
EOF
        end
      end

      def self.string_interp(str, vars)
        str.gsub /:[a-z_]+\b/ do |match|
          sym = match[1..-1].to_sym
          if vars.has_key? sym
            vars[sym]
          else
            match
          end
        end
      end

      def on_failure_mail_exception(exception, *args)
        return if @exception_mail_already_sent

        opts = Resque::Plugins::ExceptionMailer.defaults
        [:host, :port, :helo, :username, :password, :subject, :body, :from, :to].each do |sym|
          value = instance_variable_get :"@exception_mail_#{sym}"
          opts[sym] = value unless value.nil?
        end

        vars = {
          :type => exception.class.name,
          :message => exception.message,
          :backtrace => exception.backtrace.join("\n"),
          :job => self.name,
          :args => args.inspect,
          :pid => $$
        }

        Net::SMTP.start(opts[:host], opts[:port], opts[:helo], opts[:username], opts[:password]) do |smtp|
          subject = Resque::Plugins::ExceptionMailer.string_interp(opts[:subject], vars)
          body = Resque::Plugins::ExceptionMailer.string_interp(opts[:body], vars)

          msg = <<EOF
From: #{opts[:from]}
To: #{opts[:to]}
Subject: #{subject}
Date: #{Time.now.strftime("%a, %d %b %Y %H:%M:%S %z")}

#{body}
EOF

          smtp.send_message msg, opts[:from], opts[:to]
        end

        @exception_mail_already_sent = true
      rescue
      end
    end
  end
end
