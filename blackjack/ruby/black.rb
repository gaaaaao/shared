#!/opt/csw/bin/ruby

require 'cards'
require 'blackjack'

$table_min = 5.00
$table_limit = 1000.00

# XXX make configurable
$shoe = Cards::Shoe.new
$player_purse = Blackjack::Purse.new(1000.00, $table_min, $table_limit)

$player_hand = Blackjack::PlayerHand.new($shoe, $player_purse)
$dealer_hand = Blackjack::DealerHand.new($shoe)

def play_one_hand
  $player_purse.bet!
  $player_hand.deal!
  $dealer_hand.deal!

  puts ""
  $dealer_hand.show false
  puts ""
  $player_hand.show
  printf "Bet: $%.2f\n", $player_purse.curr_bet
  puts ""

  playersbest = $player_hand.play!
  if playersbest == 0
    puts "Dealer wins"
    $player_purse.lose!
    return
  end

  if $player_hand.blackjack? and not $dealer_hand.blackjack?
    puts "Player wins"
    $player_purse.blackjack!
    return
  end

  puts ""

  dealersbest = $dealer_hand.play!
  if dealersbest == 0
    puts "Player wins"
    $player_purse.win!
    return
  end

  puts ""
  $dealer_hand.show true
  puts ""
  $player_hand.show
  puts ""

  if dealersbest > playersbest
    puts "Dealer wins"
    $player_purse.lose!
  elsif playersbest > dealersbest
    puts "Player wins"
    $player_purse.win!
  else
    puts "Push"
    $player_purse.push!
  end
end

puts ("You have: $%.2f" % $player_purse.purse)
while true do
  $player_hand.muck!
  $dealer_hand.muck!

  play_one_hand

  if $player_purse.broke?
    puts "You're out of money!"
    break
  end

  printf "You have: $%.2f\n", $player_purse.purse

  if Blackjack.get_resp("Continue ([Y]es or [N]o) ([Y]N)? ",
                       "Please anser [Y]es or [N]o (default Y): ",
                       {"y" => :yes, "n" => :no}, true) == :no
    break
  end
end
