#!/usr/bin/env ruby
require 'watir'
require 'telegram/bot'

Telegram.bots_config = {
  default: '$SECRET_TELEGRAM_TOKEN' #change me
}

Telegram.bot.get_updates

chat_id = '$MY_CHAT_ID' #change me

def log (message) puts "  #{message}" end
def success (message) puts "+ #{message}" end
def fail (message) puts "- #{message}" end
def notify (message)
  success message.upcase
  system 'osascript -e \'Display notification "Bürgerbot" with title "%s"\'' % message
rescue StandardError => e
end

def appointmentAvailable? (b)
  url = 'https://service.berlin.de/terminvereinbarung/termin/day/1627768800/'
  puts '-'*80
  log 'Trying again'
  b.goto url
  log 'Page loaded'
  link = b.element css: '.calendar-month-table:first-child td.buchbar a'
  if link.exists?
    #link.click
    notify 'An appointment is available.'
    #log 'Enter y to keep searching or anything else to quit.'
    Telegram.bot.send_message(chat_id: '-376603099', text: 'An appointment is available: https://service.berlin.de/terminvereinbarung/termin/day/1627768800/')
    return false
  else
    fail 'No luck this time.'
    return false
  end
rescue StandardError => e
  fail 'Error encountered.'
  puts e.inspect
  return false
end

b = Watir::Browser.new
Telegram.bot.send_message(chat_id: chat_id, text: 'starting bot...')

until appointmentAvailable? b
  log 'Sleeping.'
  sleep 120
end
