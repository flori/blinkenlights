#!/usr/bin/env ruby

base = File.basename(Dir.pwd)
if base == 'tests' || base =~ /file-tail/
	Dir.chdir('..') if base == 'tests'
	$LOAD_PATH.unshift(File.join(Dir.pwd, 'lib'))
end

require 'test/unit'
require 'blinkenlights'

class TC_BlinkenLights < Test::Unit::TestCase
  def setup
    @bl = BlinkenLights.new
    @old_leds = get_leds
  end

  def get_leds
    [ @bl.left, @bl.middle, @bl.right ]
  end

  def teardown
    @bl.close unless @bl.closed?
  end

  def test_close
    assert !@bl.closed?
    @bl.close
    assert @bl.closed?
    assert_raises(IOError) { @bl.flash }
  end
  
  def test_block_open
    bl2 = BlinkenLights.open do |bl|
      assert !bl.closed?
      assert bl.flash
      :foo
    end
    assert_equal :foo, bl2
  end

  def test_no_block_open
    bl2 = BlinkenLights.open
    assert_kind_of BlinkenLights, bl2
    assert bl2.close
  end

  def test_reset
    @bl.random
    @bl.reset
    assert_equal get_leds, @old_leds
  end

  def test_off
    @bl.random
    @bl.off
    assert !@bl.left
    assert !@bl.middle
    assert !@bl.right
  end

  def test_on
    @bl.random
    @bl.on
    assert @bl.left
    assert @bl.middle
    assert @bl.right
  end

  def test_on
    @bl.random
    @bl.flash
    assert !@bl.left
    assert !@bl.middle
    assert !@bl.right
  end

  def test_digital
    @bl.random
    for i in 0..8
      @bl.digital = i
      assert_equal i % 8, @bl.digital
    end
  end

  def test_left_to_right
    @bl.random
    @bl.left_to_right
    assert !@bl.left
    assert !@bl.middle
    assert @bl.right
  end

  def test_right_to_left
    @bl.random
    @bl.right_to_left
    assert @bl.left
    assert !@bl.middle
    assert !@bl.right
  end

  def test_circle
    @bl.random
    @bl.circle
    assert @bl.left
    assert !@bl.middle
    assert !@bl.right
  end

  def test_reverse_circle
    @bl.random
    @bl.reverse_circle
    assert !@bl.left
    assert !@bl.middle
    assert @bl.right
  end

  def test_converge
    @bl.random
    @bl.converge
    assert !@bl.left
    assert @bl.middle
    assert !@bl.right
  end
  
  def test_diverge
    @bl.random
    @bl.diverge
    assert @bl.left
    assert !@bl.middle
    assert @bl.right
  end

  def test_left
    @bl.random
    @bl.left = false
    assert !@bl.left
    @bl.left = true
    assert @bl.left
    @bl.toggle_left
    assert !@bl.left
    @bl.toggle_left
    assert @bl.left
  end

  def test_middle
    @bl.random
    @bl.middle = false
    assert !@bl.middle
    @bl.middle = true
    assert @bl.middle
    @bl.toggle_middle
    assert !@bl.middle
    @bl.toggle_middle
    assert @bl.middle
  end

  def test_right
    @bl.random
    @bl.right = false
    assert !@bl.right
    @bl.right = true
    assert @bl.right
    @bl.toggle_right
    assert !@bl.right
    @bl.toggle_right
    assert @bl.right
  end

  def test_num
    @bl.random
    @bl.num = false
    assert !@bl.num
    @bl.num = true
    assert @bl.num
    @bl.toggle_num
    assert !@bl.num
    @bl.toggle_num
    assert @bl.num
  end

  def test_cap
    @bl.random
    @bl.cap = false
    assert !@bl.cap
    @bl.cap = true
    assert @bl.cap
    @bl.toggle_cap
    assert !@bl.cap
    @bl.toggle_cap
    assert @bl.cap
  end

  def test_scr
    @bl.random
    @bl.scr = false
    assert !@bl.scr
    @bl.scr = true
    assert @bl.scr
    @bl.toggle_scr
    assert !@bl.scr
    @bl.toggle_scr
    assert @bl.scr
  end
end
  # vim: set noet sw=2 ts=2:
