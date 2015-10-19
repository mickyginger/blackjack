## Deck Object
# contains suits
# can deal
# can shuffle
class Deck
  def initialize(number_of_decks=1)
    @cards = [];

    number_of_decks.times do
      ["♠︎", "♦", "♣", "♥"].each do |suit|
        (1..13).each do |value|
          case value
          when 1
            name = "A"
          when 11
            name = "J"
            value = 10
          when 12
            name = "Q"
            value = 10
          when 13
            name = "K"
            value = 10
          else
            name = value
          end
          @cards.push Card.new name, value, suit
        end
      end
    end
  end
  def shuffle_cards
    10.times do 
      @cards.shuffle!
    end
  end
  def deal(is_face_up=true)
    card = @cards.pop
    card.set_is_face_up is_face_up
    return card
  end
end

## Card Object
# has value
# has name
class Card
  attr_reader :name, :suit, :value, :is_face_up
  def initialize(name, value, suit_name, is_face_up=true)
    @name = name
    @value = value
    @suit = suit_name
    @is_face_up = is_face_up
  end
  def set_is_face_up(is_face_up=true)
    @is_face_up = is_face_up
  end
end

## Player Object
# has name
# has a hand
# can calculate current score
class Player

  attr_reader :is_ready, :pot, :score
  @is_ready = false
  @is_dealer = false
  @pot = nil
  @score = 0

  def initialize(name, is_dealer=false)
    @name = name
    @hand = []
    @is_dealer = is_dealer
    if !is_dealer
      @pot = 1000
    end
  end
  def take_from_pot(amount)
    @pot = @pot - amount
  end
  def add_to_pot(amount)
    @pot = @pot + amount
  end
  def make_ready
    @is_ready = true
  end
  def receive_card(card)
    @hand.push card
    if card.is_face_up
      @score = @score.to_i + card.value
    end
  end
  def reset
    @hand = []
    @is_ready = false
    @score = 0
  end
  def show_cards
    ## some ascii art to display the card
    puts "#{@name.upcase}"
    print " ------  " * @hand.length + "\n"
    @hand.each do |card|
      if card.is_face_up
        print "|#{card.name}#{card.suit}" + " " * (5 - card.name.to_s.length) + "| "
      else
        print "|      | "
      end
    end
    print "\n"
    print "|      | " * @hand.length + "\n"
    print "|      | " * @hand.length + "\n"
    print "|      | " * @hand.length + "\n"
    @hand.each do |card|
      if card.is_face_up
        print "|" + " " * (5 - card.name.to_s.length) + "#{card.suit}#{card.name}| "
      else
        print "|      | "
      end
    end
    print "\n"
    print " ------  " * @hand.length + "\n"
    print (@score > 21 ? "BUST" : "#{@score}") + "\n"
    print "\n"
  end
  def turn_cards_over
    @hand.each do |card|
      if !card.is_face_up
        card.set_is_face_up
        @score = @score + card.value
      end
    end
  end
end

## Game Object
# has a deck
# can deal
# can compare players' scores
# can decide the winner
class Game
  def initialize
    @deck = Deck.new
    @dealer = Player.new("Dealer", true)
    @player = Player.new("Player")
    play
  end
  def get_header

    puts `clear`

    puts '$$$$$$$\  $$\                     $$\                               $$\       '
    puts '$$  __$$\ $$ |                    $$ |                              $$ |      '
    puts '$$ |  $$ |$$ | $$$$$$\   $$$$$$$\ $$ |  $$\ $$\  $$$$$$\   $$$$$$$\ $$ |  $$\ '
    puts '$$$$$$$\ |$$ | \____$$\ $$  _____|$$ | $$  |\__| \____$$\ $$  _____|$$ | $$  |'
    puts '$$  __$$\ $$ | $$$$$$$ |$$ /      $$$$$$  / $$\  $$$$$$$ |$$ /      $$$$$$  / '
    puts '$$ |  $$ |$$ |$$  __$$ |$$ |      $$  _$$<  $$ |$$  __$$ |$$ |      $$  _$$<  '
    puts '$$$$$$$  |$$ |\$$$$$$$ |\$$$$$$$\ $$ | \$$\ $$ |\$$$$$$$ |\$$$$$$$\ $$ | \$$\ '
    puts '\_______/ \__| \_______| \_______|\__|  \__|$$ | \_______| \_______|\__|  \__|'
    puts '                                      $$\   $$ |                              '
    puts '                                      \$$$$$$  |                              '
    puts '                                       \______/                               '
    print "POT TOTAL: $#{@player.pot}\n\n"
  end
  def get_winner
    winning_score = 0
    winning_player
    players.each do |player|
      if player.score > winning_score
        winning_score = player.score
        winning_player = player
      end
    end
  end
  def reset
    @deck = Deck.new
    @dealer.reset
    @player.reset
    play
  end
  def find_winner

    if @dealer.score > 21 || @dealer.score < @player.score
      puts "Well done, you win"
      return @player.add_to_pot(@stake * 2)
    end

    if @dealer.score == @player.score
      puts "It's a tie"
      return @player.add_to_pot(@stake)
    end

    puts "Dealer wins"
  end
  def play
    get_header

    @deck.shuffle_cards
    2.times do |n|
      @player.receive_card @deck.deal
      @dealer.receive_card @deck.deal(n==1)
    end

    puts "How much would you like to bet?"
    @stake = gets.chomp.to_i

    until @stake <= @player.pot
      puts "You can't bet what you don't have... How much would you like to bet?"
      @stake = gets.chomp.to_i
    end

    @player.take_from_pot(@stake)

    get_header

    @dealer.show_cards
    @player.show_cards

    while @player.score <= 21 && !@player.is_ready do

      puts "Would you like to stand or hit? (S/H)"

      case gets.chomp.upcase
      when "H", "HIT"
        get_header

        @player.receive_card @deck.deal
        @dealer.show_cards
        @player.show_cards
      when "S", "STAND"
        @player.make_ready
      else
        puts "Please enter S or H"
      end
    end
    if @player.is_ready
      get_header

      @dealer.turn_cards_over
      @dealer.show_cards

      @player.show_cards

      while @dealer.score < 17 do
        @dealer.receive_card @deck.deal
        get_header

        @dealer.show_cards
        @player.show_cards
      end

      find_winner
    end
    if @player.score > 21
      puts "Bust -- Dealer wins"
    end
    if @player.pot > 0
      puts "Play again? (Y/N)"
      case gets.chop.upcase
      when "YES", "Y"
        reset
      when "NO", "N"
        puts `clear`
        exit
      end
    else
      puts "You're out of money... Start over? (Y/N)"
      case gets.chop.upcase
      when "YES", "Y"
        initialize
      when "NO", "N"
        puts `clear`
        exit
      end
    end
  end
end

game = Game.new