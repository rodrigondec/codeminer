# frozen_string_literal: true

require_relative '../kill'
require_relative '../player'
require_relative '../game'
require 'test/unit'

class TestGame < Test::Unit::TestCase

  def setup
    @user_info_line = '20:34 ClientUserinfoChanged: 2 n\Isgalamido\t\0\model\xian/default\hmodel\xian/default\g_redteam\\g_blueteam\\c1\4\c2\5\hc\100\w\0\l\0\tt\0\tl\0'
    @kill_line = '20:54 Kill: 1022 2 22: <world> killed Isgalamido by MOD_TRIGGER_HURT'

    @game = Game.new('Game 1')
  end

  def test_creation
    game = Game.new('Game 1')
    assert_instance_of(Game, game)
    assert_equal('Game 1', game.name)
    assert_equal({}, game.players)
    assert_equal([], game.kills)
  end

  def test_name_typecheck
    assert_raise(RuntimeError) { Game.new(1) }
  end

  def test_info
    info = {}
    info['Game 1'] = { total_kills: 0, players: [], kills: [] }
    assert_equal(info, @game.info)
  end

  def test_players_info
    @game.send(:add_player, 'test')
    assert_equal(['test'], @game.send(:players_info))
  end

  def test_killers_info
    @game.send(:add_player, 'test')
    @game.players['test'].increment_kill
    assert_equal([{ name: 'test', kills: 1 }], @game.send(:kills_info))
  end

  def test_add_player
    @game.send(:add_player, 'test')
    assert_equal(1, @game.players.length)
    assert_true(@game.players.key?('test'))
    player = @game.players['test']
    assert_instance_of(Player, player)
    assert_equal('test', player.name)
  end

  def test_add_kill
    killer = Player.new('killer')
    victim = Player.new('victim')
    @game.send(:add_kill, killer, victim, 'test')
    assert_equal(1, @game.kills.length)
    kill = @game.kills[0]
    assert_instance_of(Kill, kill)
    assert_equal(killer, kill.killer)
    assert_equal(victim, kill.victim)
    assert_equal('test', kill.mean)
  end

  def test_create_or_get_player
    @game.send(:create_or_get_player, 'test')
    assert_equal(1, @game.players.length)
    assert_true(@game.players.key?('test'))
    player = @game.players['test']

    @game.send(:create_or_get_player, 'test')
    assert_equal(1, @game.players.length)
    assert_true(@game.players.key?('test'))
    player2 = @game.players['test']

    assert_equal(player2, player)
  end

  def test_get_player
    player = @game.send(:get_player, 'test')
    assert_equal(1, @game.players.length)
    assert_true(@game.players.key?('test'))
    player2 = @game.players['test']

    player3 = @game.send(:get_player, 'test')

    assert_equal(player2, player)
    assert_equal(player3, player)
  end

  def test_get_player_world
    player = @game.send(:get_player, '<world>')
    assert_equal(0, @game.players.length)

    assert_equal(nil, player)
  end

  def test_process_kill
    killer_name = 'killer'
    victim_name = 'victim'
    mean = 'test'

    @game.send(:process_kill, killer_name, victim_name, mean)
    assert_equal(2, @game.players.length)

    assert_true(@game.players.key?('killer'))
    killer = @game.players['killer']

    assert_true(@game.players.key?('victim'))
    victim = @game.players['victim']

    assert_equal(1, @game.kills.length)
    kill = @game.kills[0]
    assert_instance_of(Kill, kill)
    assert_equal(killer, kill.killer)
    assert_equal(victim, kill.victim)
    assert_equal('test', kill.mean)
  end

  def test_process_kill_line
    @game.process_kill_line(@kill_line)

    assert_equal(1, @game.players.length)

    assert_true(@game.players.key?('Isgalamido'))
    isgalamamido = @game.players['Isgalamido']

    assert_equal(-1, isgalamamido.kills)

    assert_equal(1, @game.kills.length)
    kill = @game.kills[0]
    assert_equal(nil, kill.killer)
    assert_equal(isgalamamido, kill.victim)
    assert_equal('MOD_TRIGGER_HURT', kill.mean)
  end

  def test_process_user_info_line
    @game.process_user_info_line(@user_info_line)

    assert_equal(1, @game.players.length)

    assert_true(@game.players.key?('Isgalamido'))
    isgalamamido = @game.players['Isgalamido']
    assert_equal('Isgalamido', isgalamamido.name)
  end

end