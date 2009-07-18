begin
  require 'Win32API'
rescue LoadError
end
require 'blinkenlights/version'

# Class that implements the functionality of the BlinkenLights library.
class BlinkenLights

  # Module to hold the BlinkenLights constants.
  module Constants
    # The default tty. It happens to be the one, I run X on. ;)
    DEF_TTY   = ENV['BLINKENLIGHTS_TTY'] || '/dev/tty7'

    # DEF_DELAY is the default standard delay in seconds, that is slept
    # everytime the LED state is changed. If it is too small your keyboard may
    # become confused about its LEDs' status.
    DEF_DELAY = 0.1

    # Scroll Lock LED (from /usr/include/linux/kd.h)
    LED_SCR   = 0x01

    # Num Lock LED (from /usr/include/linux/kd.h)
    LED_NUM   = 0x02

    # Caps Lock LED (from /usr/include/linux/kd.h)
    LED_CAP   = 0x04

    # Return current LED state (from /usr/include/linux/kd.h)
    KDGETLED  = 0x4B31

    # Set LED state [lights, not flags] (from /usr/include/linux/kd.h)
    KDSETLED  = 0x4B32

    # In order from left to right. This setting may have to be tweaked, if your
    # keyboard has some unusual LED positions.
    LEDS        = [ :LED_NUM, :LED_CAP, :LED_SCR ]

    # Values for LEDs from left to right
    LEDS_VALUES = LEDS.map { |c| self.const_get(c) }

    # In order from lowest to highest
    DIGITAL     = [ :LED_SCR, :LED_NUM, :LED_CAP ]

    # The left LED
    LED_LEFT    = 4

    # The middle LED
    LED_MIDDLE  = 2

    # The right LED
    LED_RIGHT   = 1

    # None of the LEDs
    LED_NONE    = 0

    # All of the LEDs
    LED_ALL     = 7

    if defined? ::Win32API
      # Windows Virtual Key code for caps lock
      VK_CAPITAL  = 0x14

      # Windows Virtual Key code for num lock
      VK_NUMLOCK  = 0x90

      # Windows Virtual Key code for scroll lock
      VK_SCROLL   = 0x91

      # Mapping from UNIX LEDs to Windows Virtual Key codes
      WINDOWS_LEDS = {
        LED_SCR => VK_SCROLL,
        LED_NUM => VK_NUMLOCK,
        LED_CAP => VK_CAPITAL
      }

      # Windows key released: Windows keybd_event() constant KEYEVENTF_KEYUP
      WIN_KEY_UP = 0x26
     
      # Win32API GetKeyState function
      GetKeyState = ::Win32API.new("user32", "GetKeyState", ["i"], "i")

      # Win32API Keybd_event function
      Keybd_event = ::Win32API.new("user32", "keybd_event", %w[i i i i], "v")
    end
  end
  include Constants

  if defined? ::Win32API
    def initialize(ignored = nil, delay = DEF_DELAY) # :nodoc:
      @tty      = File.new('NUL', File::RDWR)
      @delay    = delay
      @old_leds = get
    end
  else
    # Creates a BlinkenLights instance for _tty_, a full pathname like
    # '/dev/tty8' to control the LEDs. This parameter is ignored under the
    # Windows operating system.
    #
    # _delay_ is the standard delay in seconds,
    # that is slept everytime the LED state is changed. If _delay_ is too small
    # your keyboard may become confused about its LEDs' status.
    def initialize(tty = DEF_TTY, delay = DEF_DELAY)
      @tty      = File.new(tty, File::RDWR)
      @delay    = delay
      @old_leds = get
    end
  end


  # The standard delay of this BlinkenLights instance.
  attr_accessor :delay

  # Creates a BlinkenLights instance and yields to it. After the block returns
  # the BlinkenLights#close method is called.
  def self.open(tty = DEF_TTY, delay = DEF_DELAY)
    obj = new(tty, delay)
    if block_given?
      begin
        yield obj
      ensure
        obj.close if obj
      end
    else
      obj
    end
  end

  # Close the open console tty after resetting LEDs to the original state.
  def close
    reset
    @tty.close
    self
  end

  # Return true if the constants tty has been closed.
  def closed?
    @tty.closed?
  end

  # Resets the LED state to the starting state (when the BlinkenLights object
  # was created).
  def reset
    set @old_leds
    self
  end
  
  # Switch off all LEDs.
  def off
    set LED_NONE
    self
  end
  
  # Switch on all LEDs.
  def on
    set LED_ALL
    self
  end

  # First switches all LEDs on, then off. Sleep for _delay_ seconds after
  # switching them on.
  def flash(delay = 0.0)
    on
    sleep delay
    off
  end

  # Set LEDs to _number_ in binary digital mode.
  def digital=(number)
    number %= 8
    setting = 0
    0.upto(2) do |i|
      if number[i] == 1
        setting |= 1 << DIGITAL.index(LEDS[2 - i])
      end
    end
    set setting
  end
  
  # Return the state of the LEDs expressed in binary digital mode.
  def digital
    setting = get
    result  = 0
    2.downto(0) do |i|
      if setting[i] == 1
        result |= 1 << (2 - LEDS_VALUES.index(1 << i))
      end
    end
    result
  end

  # Blink all the LEDs from the left to the right. Sleep for _delay_ seconds in
  # between.
  def left_to_right(delay = 0.0)
    for i in [ LED_LEFT, LED_MIDDLE, LED_RIGHT ]
      self.digital = i
      sleep delay
    end
    self
  end

  # Blink all the LEDs from the right to the left. Sleep for _delay_ seconds in
  # between.
  def right_to_left(delay = 0.0)
    for i in [ LED_RIGHT, LED_MIDDLE, LED_LEFT ]
      self.digital = i
      sleep delay
    end
    self
  end

  # Blink all the LEDs from the left to the right, and then from the right to
  # the left. Sleep for _delay_ seconds in between.
  def circle(delay = 0.0)
    left_to_right(delay)
    right_to_left(delay)
    self
  end

  # Blink all the LEDs from the right to the left, and then from the left to
  # the right. Sleep for _delay_ seconds in between.
  def reverse_circle(delay = 0.0)
    right_to_left(delay)
    left_to_right(delay)
    self
  end

  # Switch some of the LEDs on by random. Then sleep for _delay_ seconds.
  def random(delay = 0.0)
    self.digital = rand(LED_ALL + 1)
    sleep delay
    self
  end

  # Converge, that is, first blink the outer LEDs, then blink the inner LED.
  # Sleep for _delay_ seconds in between.
  def converge(delay = 0.0)
    for i in [ LED_LEFT|LED_RIGHT, LED_MIDDLE ]
      self.digital = i
      sleep delay
    end
    self
  end

  # Diverge, that is, first blink the inner LED, then blink the outer LEDs.
  # Sleep for _delay_ seconds in between.
  def diverge(delay = 0.0)
    for i in [ LED_MIDDLE, LED_LEFT|LED_RIGHT ]
      self.digital = i
      sleep delay
    end
    self
  end

  # Return the state of the Scroll Lock LED: true for switched on, false for
  # off.
  def scr
    (get & LED_SCR) != LED_NONE
  end

  # Switch the Scroll Lock LED on, if _toggle_ is true, off, otherwise.
  def scr=(toggle)
    old = get
    if toggle
      set old | LED_SCR
    else
      set old & ~LED_SCR
    end
  end

  # Switch the Scroll Lock LED on, if it was off before. Switch the Scroll Lock
  # LED off, if it was on before. 
  def toggle_scr(delay = 0.0)
    self.scr = !scr
    sleep delay
    self
  end

  # Return the state of the Caps Lock LED: true for switched on, false for off.
  def cap
    (get & LED_CAP) != LED_NONE
  end

  # Switch the Caps Lock LED on, if _toggle_ is true, off, otherwise.
  def cap=(toggle)
    old = get
    if toggle
      set old | LED_CAP
    else
      set old & ~LED_CAP
    end
  end

  # Switch the Caps Lock LED on, if it was off before. Switch the Caps Lock
  # LED off, if it was on before. 
  def toggle_cap(delay = 0.0)
    self.cap = !cap
    sleep delay
    self
  end

  # Return the state of the Num Lock LED: true for switched on, false for off.
  def num
    (get & LED_NUM) != LED_NONE
  end

  # Switch the Num Lock LED on, if _toggle_ is true, off, otherwise.
  def num=(toggle)
    old = get
    if toggle
      set old | LED_NUM
    else
      set old & ~LED_NUM
    end
  end

  # Switch the Num Lock LED on, if it was off before. Switch the Num Lock LED
  # off, if it was on before. 
  def toggle_num(delay = 0.0)
    self.num = !num
    self
  end

  # Return the state of the left LED: true for switched on, false for
  # off.
  def left
    (digital & LED_LEFT) != LED_NONE
  end

  # Switch the left LED on, if _toggle_ is true, off, otherwise.
  def left=(toggle)
    old = digital
    if toggle
      self.digital = old | LED_LEFT
    else
      self.digital = old & ~LED_LEFT
    end
  end

  # Switch the left LED on, if it was off before. Switch the left
  # LED off, if it was on before. 
  def toggle_left(delay = 0.0)
    self.left = !left
    sleep delay
    self
  end

  # Return the state of the middle LED: true for switched on, false for off.
  def middle
    (digital & LED_MIDDLE) != LED_NONE
  end

  # Switch the middle LED on, if _toggle_ is true, off, otherwise.
  def middle=(toggle)
    old = digital
    if toggle
      self.digital = old | LED_MIDDLE
    else
      self.digital = old & ~LED_MIDDLE
    end
  end

  # Switch the middle LED on, if it was off before. Switch the middle LED off,
  # if it was on before. 
  def toggle_middle(delay = 0.0)
    self.middle = !middle
    sleep delay
    self
  end

  # Return the state of the right LED: true for switched on, false for off.
  def right
    (digital & LED_RIGHT) != LED_NONE
  end

  # Switch the right LED on, if _toggle_ is true, off, otherwise.
  def right=(toggle)
    old = digital
    if toggle
      self.digital = old | LED_RIGHT
    else
      self.digital = old & ~LED_RIGHT
    end
  end

  # Switch the right LED on, if it was off before. Switch the right off, if it
  # was on before. 
  def toggle_right(delay = 0.0)
    self.right = !right
    self
  end

  if defined? ::Win32API
    def set(number) # :nodoc:
      raise IOError, 'closed stream' if closed?
      WINDOWS_LEDS.each do |nix, win|
        if (number & nix != 0) ^ (GetKeyState.call(win) != 0)
          Keybd_event.call(win, 0, 0, 0)
          Keybd_event.call(win, 0, WIN_KEY_UP, 0)
        end
      end
      sleep @delay
      number
    end

    def get # :nodoc:
      raise IOError, 'closed stream' if closed?
      WINDOWS_LEDS.inject(0) do |sum, (nix, win)|
        sum | ((GetKeyState.call(win) != 0) ? nix : 0)
      end
    end
  else
    # Set the state of the LEDs to integer _number_. (Quite low level)
    def set(number)
      @tty.ioctl(KDSETLED, number)
      sleep @delay
      number
    end

    # Return the state of the LEDs as an integer _number_. (Quite low level)
    def get
      char = [0].pack('C')
      @tty.ioctl(KDGETLED, char)
      char.unpack('C')[0]
    end
  end

  # Return a string representation of this BlinkenLights instance, showing
  # some interesting data.
  def to_s
    if @tty.closed?
      "#<#{self.class}: closed>"
    else
      "#<#{self.class}: delay=#{@delay}s, tty=#{@tty.path}," +
      " LEDs=#{'%03b' % self.digital}>"
    end
  end

  alias inspect to_s
end
