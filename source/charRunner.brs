' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Lode Runner Channel - http://github.com/lvcabral/Lode-Runner-Roku
' **
' **  Created: September 2016
' **  Updated: November 2016
' **
' **  Remake in Brightscropt developed by Marcelo Lv Cabral - http://lvcabral.com
' ********************************************************************************************************
' ********************************************************************************************************

Function CreateRunner(level as object) as object
    this = {}
    'Constants
    this.const = m.const
	'Controller
	this.cursors = GetControl(m.settings.controlMode)
    this.sounds = m.sounds
    'Properties
    this.charType = "runner"
    this.score = 0
    this.usedCheat = false
    this.health = m.const.START_HEALTH
    'Methods
    this.startLevel = start_level_runner
    this.update = update_runner
    this.canDig = can_dig
    this.keyU = key_u
    this.keyD = key_d
    this.keyL = key_l
    this.keyR = key_r
    this.keyDG = key_dg
    this.keyDL = key_dl
    this.keyDR = key_dr
    'Initialize level variables
    this.startLevel(level)
    return ImplementActor(this)
End Function

Sub start_level_runner(level as object)
    m.alive = true
    m.level = level
    m.blockX = level.runner.x
    m.blockY = level.runner.y
    m.offsetX = 0
    m.offsetY = 0
    m.charAction = "runRight"
    m.frameName = "runner_00"
    m.frame = 1
    m.state = 0
    m.success = false
    m.cursors.reset()
End Sub

Sub update_runner()
    'Check level complete
    if m.blockY = 0 and m.offsetY = 0 and m.level.gold = 0
        m.success = true
        return
    end if
    'Update runner position
    if m.state = m.STATE_FALL or m.level.status = m.const.LEVEL_STARTUP
        m.move(m.const.ACT_NONE)
    else if m.keyDG() 'Dig
        m.move(m.const.ACT_DIG)
    else if m.keyU()
        m.move(m.const.ACT_UP)
    else if m.keyD()
        m.move(m.const.ACT_DOWN)
    else if m.keyL()
        m.move(m.const.ACT_LEFT)
    else if m.keyR()
        m.move(m.const.ACT_RIGHT)
    else
        m.move(m.const.ACT_NONE)
    end if
    'Falling sound
    if m.state = m.STATE_FALL and m.level.status <> m.const.LEVEL_STARTUP
        if m.sounds.wav.clip <> "fall" or m.sounds.wav.cycles = 0
            PlaySound("fall")
        end if
    else if m.sounds.wav.clip = "fall"
        StopSound()
    end if
    'Restore after dig
    if Left(m.charAction, 3) = "dig" and m.state <> m.STATE_MOVE
        m.charAction = m.charAction.Replace("dig", "run")
        m.state = m.STATE_MOVE
    end if
    'Update animation frame
    m.frameUpdate()
End Sub

Function can_dig() as boolean
    x = m.blockX
    y = m.blockY
    rsp = false
    if (m.keyDL() or (m.charAction = "runLeft" and not m.keyDR())) and x > 1
        if y < m.const.TILES_Y and x > 0
            lTile = m.level.map[x-1][y+1]
            dTile = m.level.map[x-1][y]
            if lTile.act = m.const.MAP_BLOCK and dTile.act = m.const.MAP_EMPTY
                if dTile.base <> m.const.MAP_GOLD and not dTile.guard
                    rsp = true
                end if
            end if
        end if
    else if (m.keyDR() or m.charAction = "runRight") and x < m.const.TILES_X - 2
        if y < m.const.TILES_Y and x < m.const.TILES_X
            rTile = m.level.map[x+1][y+1]
            dTile = m.level.map[x+1][y]
            if rTile.act = m.const.MAP_BLOCK and dTile.act = m.const.MAP_EMPTY
                if dTile.base <> m.const.MAP_GOLD and not dTile.guard
                    rsp = true
                end if
            end if
        end if
    end if
    return rsp
End Function

Function key_u() as boolean
    return m.cursors.up
End Function

Function key_d() as boolean
    return m.cursors.down
End Function

Function key_l() as boolean
    return m.cursors.left
End Function

Function key_r() as boolean
    return m.cursors.right
End Function

Function key_dg() as boolean
    return m.cursors.dig
End Function

Function key_dl() as boolean
    return m.cursors.digLeft
End Function

Function key_dr() as boolean
    return m.cursors.digRight
End Function

Sub AddScore(points as integer)
    g = GetGlobalAA()
    g.runner.score += points
    g.statusRedraw = true
End Sub
