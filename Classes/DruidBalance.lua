-- DruidBalance.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'DRUID' then
    local spec = Hekili:NewSpecialization( 102, true )

    spec:RegisterResource( Enum.PowerType.LunarPower, {
        fury_of_elune = {            
            aura = "fury_of_elune_ap",

            last = function ()
                local app = state.buff.fury_of_elune_ap.applied
                local t = state.query_time

                return app + floor( ( t - app ) / 0.5 ) * 0.5
            end,

            interval = 0.5,
            value = 2.5
        }
    } )


    spec:RegisterResource( Enum.PowerType.Mana )
    spec:RegisterResource( Enum.PowerType.Energy )
    spec:RegisterResource( Enum.PowerType.ComboPoints )
    spec:RegisterResource( Enum.PowerType.Rage )
    
    -- Talents
    spec:RegisterTalents( {
        natures_balance = 22385, -- 202430
        warrior_of_elune = 22386, -- 202425
        force_of_nature = 22387, -- 205636

        tiger_dash = 19283, -- 252216
        renewal = 18570, -- 108238
        wild_charge = 18571, -- 102401

        feral_affinity = 22155, -- 202157
        guardian_affinity = 22157, -- 197491
        restoration_affinity = 22159, -- 197492

        mighty_bash = 21778, -- 5211
        mass_entanglement = 18576, -- 102359
        typhoon = 18577, -- 132469

        soul_of_the_forest = 18580, -- 114107
        starlord = 21706, -- 202345
        incarnation = 21702, -- 102560

        stellar_drift = 22389, -- 202354
        twin_moons = 21712, -- 279620
        stellar_flare = 22165, -- 202347

        shooting_stars = 21648, -- 202342
        fury_of_elune = 21193, -- 202770
        new_moon = 21655, -- 274281
    } )

    
    -- PvP Talents
    spec:RegisterPvpTalents( { 
        adaptation = 3543, -- 214027
        relentless = 3542, -- 196029
        gladiators_medallion = 3541, -- 208683

        celestial_downpour = 183, -- 200726
        celestial_guardian = 180, -- 233754
        crescent_burn = 182, -- 200567
        cyclone = 857, -- 209753
        deep_roots = 834, -- 233755
        dying_stars = 822, -- 232546
        faerie_swarm = 836, -- 209749
        ironfeather_armor = 1216, -- 233752
        moon_and_stars = 184, -- 233750
        moonkin_aura = 185, -- 209740
        prickling_thorns = 3058, -- 200549
        protector_of_the_grove = 3728, -- 209730
        thorns = 3731, -- 236696
    } )

    
    spec:RegisterPower( "lively_spirit", 279642, {
        id = 279648,
        duration = 20,
        max_stack = 1,
    } )


    -- Auras
    spec:RegisterAuras( {
        aquatic_form = {
            id = 276012,
        },
        astral_influence = {
            id = 197524,
        },
        barkskin = {
            id = 22812,
            duration = 12,
            max_stack = 1,
        },
        bear_form = {
            id = 5487,
            duration = 3600,
            max_stack = 1,
        },
        blessing_of_cenarius = {
            id = 238026,
            duration = 60,
            max_stack = 1,
        },
        blessing_of_the_ancients = {
            id = 206498,
            duration = 3600,
            max_stack = 1,
        },
        cat_form = {
            id = 768,
            duration = 3600,
            max_stack = 1,
        },
        celestial_alignment = {
            id = 194223,
            duration = 20,
            max_stack = 1,
        },
        dash = {
            id = 1850,
            duration = 10,
            max_stack = 1,
        },
        eclipse = {
            id = 279619,
        },
        empowerments = {
            id = 279708,
        },
        entangling_roots = {
            id = 339,
            duration = 30,
            type = "Magic",
            max_stack = 1,
        },
        feline_swiftness = {
            id = 131768,
        },
        flask_of_the_seventh_demon = {
            id = 188033,
            duration = 3600.006,
            max_stack = 1,
        },
        flight_form = {
            id = 276029,
        },
        force_of_nature = {
            id = 205644,
            duration = 15,
            max_stack = 1,
        },
        frenzied_regeneration = {
            id = 22842,
            duration = 3,
            max_stack = 1,
        },
        fury_of_elune_ap = {
            id = 202770,
            duration = 8,
            max_stack = 1,
    
            generate = function ()
                local foe = buff.fury_of_elune_ap
                local applied = action.fury_of_elune.lastCast
    
                if applied and now - applied < 8 then
                    foe.count = 1
                    foe.expires = applied + 8
                    foe.applied = applied
                    foe.caster = "player"
                    return
                end
    
                foe.count = 0
                foe.expires = 0
                foe.applied = 0
                foe.caster = "nobody"
            end,
        },
        growl = {
            id = 6795,
            duration = 3,
            max_stack = 1,
        },
        incarnation = {
            id = 102560,
            duration = 30,
            max_stack = 1,
            copy = "incarnation_chosen_of_elune"
        },
        ironfur = {
            id = 192081,
            duration = 7,
            max_stack = 1,
        },
        legionfall_commander = {
            id = 233641,
            duration = 3600,
            max_stack = 1,
        },
        lunar_empowerment = {
            id = 164547,
            duration = 45,
            type = "Magic",
            max_stack = 3,
        },
        mana_divining_stone = {
            id = 227723,
            duration = 3600,
            max_stack = 1,
        },
        mass_entanglement = {
            id = 102359,
            duration = 30,
            type = "Magic",
            max_stack = 1,
        },
        mighty_bash = {
            id = 5211,
            duration = 5,
            max_stack = 1,
        },
        moonfire = {
            id = 164812,
            duration = 22,
            tick_time = function () return 2 * haste end,
            type = "Magic",
            max_stack = 1,
        },
        moonkin_form = {
            id = 24858,
            duration = 3600,
            max_stack = 1,
        },
        prowl = {
            id = 5215,
            duration = 3600,
            max_stack = 1,
        },
        regrowth = {
            id = 8936,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },
        shadowmeld = {
            id = 58984,
            duration = 3600,
            max_stack = 1,
        },
        sign_of_the_critter = {
            id = 186406,
            duration = 3600,
            max_stack = 1,
        },
        solar_beam = {
            id = 81261,
            duration = 3600,
            max_stack = 1,
        },
        solar_empowerment = {
            id = 164545,
            duration = 45,
            type = "Magic",
            max_stack = 3,
        },
        stag_form = {
            id = 210053,
            duration = 3600,
            max_stack = 1,
            generate = function ()
                local form = GetShapeshiftForm()
                local stag = form and form > 0 and select( 4, GetShapeshiftFormInfo( form ) )
                
                local sf = buff.stag_form

                if stag == 210053 then
                    sf.count = 1
                    sf.applied = now
                    sf.expires = now + 3600
                    sf.caster = "player"
                    return
                end

                sf.count = 0
                sf.applied = 0
                sf.expires = 0
                sf.caster = "nobody"
            end,
        },
        starfall = {
            id = 191034,
            duration = function () return pvptalent.celestial_downpour.enabled and 16 or 8 end,
            max_stack = 1,

            generate = function ()
                local sf = buff.starfall

                if now - action.starfall.lastCast < 8 then
                    sf.count = 1
                    sf.applied = action.starfall.lastCast
                    sf.expires = sf.applied + 8
                    sf.caster = "player"
                    return
                end

                sf.count = 0
                sf.applied = 0
                sf.expires = 0
                sf.caster = "nobody"
            end
        },
        starlord = {
            id = 279709,
            duration = 20,
            max_stack = 3,
        },
        stellar_drift = {
            id = 202461,
            duration = 3600,
            max_stack = 1,
        },
        stellar_flare = {
            id = 202347,
            duration = 24,
            tick_time = function () return 2 * haste end,
            type = "Magic",
            max_stack = 1,
        },
        sunfire = {
            id = 164815,
            duration = 18,
            tick_time = function () return 2 * haste end,
            type = "Magic",
            max_stack = 1,
        },
        thick_hide = {
            id = 16931,
        },
        thorny_entanglement = {
            id = 241750,
            duration = 15,
            max_stack = 1,
        },
        thrash_bear = {
            id = 192090,
            duration = 15,
            max_stack = 3,
        },
        thrash_cat ={
            id = 106830, 
            duration = function()
                local x = 15 -- Base duration
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
            tick_time = function()
                local x = 3 -- Base tick time
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
        },
        --[[ thrash = {
            id = function ()
                if buff.cat_form.up then return 106830 end
                return 192090
            end,
            duration = function()
                local x = 15 -- Base duration
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
            tick_time = function()
                local x = 3 -- Base tick time
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
        }, ]]
        tiger_dash = {
            id = 252216,
            duration = 5,
            max_stack = 1,
        },
        travel_form = {
            id = 783,
            duration = 3600,
            max_stack = 1,
        },
        treant_form = {
            id = 114282,
            duration = 3600,
            max_stack = 1,
        },
        typhoon = {
            id = 61391,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
        warrior_of_elune = {
            id = 202425,
            duration = 3600,
            type = "Magic",
            max_stack = 3,
        },
        wild_charge = {
            id = 102401,
        },
        yseras_gift = {
            id = 145108,
        },
        -- Alias for Celestial Alignment vs. Incarnation
        ca_inc = {
            alias = { "celestial_alignment", "incarnation" },
            aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
            aliasType = "buff",
            duration = function () return talent.incarnation.enabled and 30 or 20 end,
        },


        -- PvP Talents
        celestial_guardian = {
            id = 234081,
            duration = 3600,
            max_stack = 1,
        },

        cyclone = {
            id = 209753,
            duration = 6,
            max_stack = 1,
        },

        faerie_swarm = {
            id = 209749,
            duration = 5,
            type = "Magic",
            max_stack = 1,
        },

        moon_and_stars = {
            id = 234084,
            duration = 10,
            max_stack = 1,
        },

        moonkin_aura = {
            id = 209746,
            duration = 18,
            type = "Magic",
            max_stack = 3,
        },

        thorns = {
            id = 236696,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },


        -- Azerite Powers
        dawning_sun = {
            id = 276153,
            duration = 8,
            max_stack = 1,
        },

        sunblaze = {
            id = 274399,
            duration = 20,
            max_stack = 1
        },
    } )


    spec:RegisterStateFunction( "break_stealth", function ()
        removeBuff( "shadowmeld" )
        if buff.prowl.up then
            setCooldown( "prowl", 6 )
            removeBuff( "prowl" )
        end
    end )


    -- Function to remove any form currently active.
    spec:RegisterStateFunction( "unshift", function()
        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        removeBuff( "travel_form" )
        removeBuff( "aquatic_form" )
        removeBuff( "stag_form" )
        removeBuff( "celestial_guardian" )
    end )
    

    -- Function to apply form that is passed into it via string.
    spec:RegisterStateFunction( "shift", function( form )
        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        removeBuff( "travel_form" )
        removeBuff( "aquatic_form" )
        removeBuff( "stag_form" )
        applyBuff( form )
        
        if form == "bear_form" and pvptalent.celestial_guardian.enabled then
            applyBuff( "celestial_guardian" )
        end
    end )


    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]
    
        if not a or a.startsCombat then
            break_stealth()
        end 
    end )


    spec:RegisterStateExpr( "ap_check", function ()
        local a = this_action
        a = a and action[ this_action ]
        a = a and a.ap_check
    
        return a == true
    end )


    -- Simplify lookups for AP abilities consistent with SimC.
    local ap_checks = { 
        "force_of_nature", "full_moon", "half_moon", "lunar_strike", "moonfire", "new_moon", "solar_wrath", "starfall", "starsurge", "sunfire"
    }

    for i, lookup in ipairs( ap_checks ) do
        spec:RegisterStateExpr( lookup, function ()
            return action[ lookup ]
        end )
    end

    spec:RegisterStateExpr( "active_moon", function ()
        return "new_moon"
    end )

    local function IsActiveSpell( id )
        local slot = FindSpellBookSlotBySpellID( id )
        if not slot then return false end

        local _, _, spellID = GetSpellBookItemName( slot, "spell" )
        return id == spellID 
    end

    state.IsActiveSpell = IsActiveSpell
    
    spec:RegisterHook( "reset_precast", function ()
        if IsActiveSpell( class.abilities.new_moon.id ) then active_moon = "new_moon"
        elseif IsActiveSpell( class.abilities.half_moon.id ) then active_moon = "half_moon"
        elseif IsActiveSpell( class.abilities.full_moon.id ) then active_moon = "full_moon"
        else active_moon = nil end

        -- UGLY
        if talent.incarnation.enabled then
            rawset( cooldown, "ca_inc", cooldown.incarnation )
        else
            rawset( cooldown, "ca_inc", cooldown.celestial_alignment )
        end
    end )


    spec:RegisterHook( "spend", function( amt, resource )
        if level < 116 and equipped.impeccable_fel_essence and resource == "astral_power" and cooldown.celestial_alignment.remains > 0 then
            setCooldown( "celestial_alignment", max( 0, cooldown.celestial_alignment.remains - ( amt / 12 ) ) )
        end 
    end )


    -- Legion Sets (for now).
    spec:RegisterGear( 'tier21', 152127, 152129, 152125, 152124, 152126, 152128 )
        spec:RegisterAura( 'solar_solstice', {
            id = 252767,
            duration = 6,
            max_stack = 1,
         } ) 

    spec:RegisterGear( 'tier20', 147136, 147138, 147134, 147133, 147135, 147137 )
    spec:RegisterGear( 'tier19', 138330, 138336, 138366, 138324, 138327, 138333 )
    spec:RegisterGear( 'class', 139726, 139728, 139723, 139730, 139725, 139729, 139727, 139724 )

    spec:RegisterGear( "impeccable_fel_essence", 137039 )    
    spec:RegisterGear( "oneths_intuition", 137092 )
        spec:RegisterAuras( {
            oneths_intuition = {
                id = 209406,
                duration = 3600,
                max_stacks = 1,
            },    
            oneths_overconfidence = {
                id = 209407,
                duration = 3600,
                max_stacks = 1,
            },
        } )

    spec:RegisterGear( "radiant_moonlight", 151800 )
    spec:RegisterGear( "the_emerald_dreamcatcher", 137062 )
        spec:RegisterAura( "the_emerald_dreamcatcher", {
            id = 224706,
            duration = 5,
            max_stack = 2,
        } )



    -- Abilities
    spec:RegisterAbilities( {
        barkskin = {
            id = 22812,
            cast = 0,
            cooldown = 60,
            gcd = "off",
            
            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 136097,
            
            handler = function ()
                applyBuff( "barkskin" )
            end,
        },
        

        bear_form = {
            id = 5487,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132276,

            noform = "bear_form",
            
            handler = function ()
                shift( "bear_form" )
            end,
        },
        

        cat_form = {
            id = 768,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132115,

            noform = "cat_form",
            
            handler = function ()
                shift( "cat_form" )
            end,
        },
        

        celestial_alignment = {
            id = 194223,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 136060,

            notalent = "incarnation",
            
            handler = function ()
                applyBuff( "celestial_alignment" )
                if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
            end,

            copy = "ca_inc"
        },
        

        cyclone = {
            id = 209753,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            pvptalent = "cyclone",
            
            spend = 0.15,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136022,
            
            handler = function ()
                applyDebuff( "target", "cyclone" )
            end,
        },
        

        dash = {
            id = 1850,
            cast = 0,
            cooldown = 120,
            gcd = "off",
            
            startsCombat = false,
            texture = 132120,

            notalent = "tiger_dash",
            
            handler = function ()
                if not buff.cat_form.up then
                    shift( "cat_form" )
                end
                applyBuff( "dash" )
            end,
        },
        

        --[[ dreamwalk = {
            id = 193753,
            cast = 10,
            cooldown = 60,
            gcd = "spell",
            
            spend = 4,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 135763,
            
            handler = function ()
            end,
        }, ]]
        

        entangling_roots = {
            id = 339,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.18,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136100,
            
            handler = function ()
                applyDebuff( "target", "entangling_roots" )
            end,
        },
        

        faerie_swarm = {
            id = 209749,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            pvptalent = "faerie_swarm",

            startsCombat = true,
            texture = 538516,
            
            handler = function ()
                applyDebuff( "target", "faerie_swarm" )
            end,
        },
        

        ferocious_bite = {
            id = 22568,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 50,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132127,

            form = "cat_form",
            talent = "feral_affinity",
            
            usable = function () return combo_points.current > 0 end,
            handler = function ()
                --[[ if target.health.pct < 25 and debuff.rip.up then
                    applyDebuff( "target", "rip", min( debuff.rip.duration * 1.3, debuff.rip.remains + debuff.rip.duration ) )
                end ]]
                spend( combo_points.current, "combo_points" )
            end,
        },
        

        --[[ flap = {
            id = 164862,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132925,
            
            handler = function ()
            end,
        }, ]]
        

        force_of_nature = {
            id = 205636,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            spend = -20,
            spendType = "astral_power",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 132129,

            talent = "force_of_nature",

            ap_check = function()
                return astral_power.current - action.force_of_nature.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,
            
            handler = function ()
                summonPet( "treants", 10 )
            end,
        },
        

        frenzied_regeneration = {
            id = 22842,
            cast = 0,
            charges = 1,
            cooldown = 36,
            recharge = 36,
            gcd = "spell",
            
            spend = 10,
            spendType = "rage",
            
            startsCombat = false,
            texture = 132091,

            form = "bear_form",
            talent = "guardian_affinity",
            
            handler = function ()
                applyBuff( "frenzied_regeneration" )
                gain( 0.08 * health.max, "health" )
            end,
        },
        

        full_moon = {
            id = 274283,
            known = 274281,
            cast = 3,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",
            
            spend = -40,
            spendType = "astral_power",

            texture = 1392542,
            startsCombat = true,

            talent = "new_moon",
            bind = "half_moon",

            ap_check = function()
                return astral_power.current - action.full_moon.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
            usable = function () return active_moon == "full_moon" end,
            handler = function ()
                spendCharges( "new_moon", 1 )
                spendCharges( "half_moon", 1 )

                -- Radiant Moonlight, NYI.
                active_moon = "new_moon"
            end,
        },
        

        fury_of_elune = {
            id = 202770,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 132123,
            
            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                applyDebuff( "target", "fury_of_elune_ap" )
            end,
        },
        

        growl = {
            id = 6795,
            cast = 0,
            cooldown = 8,
            gcd = "off",
            
            startsCombat = true,
            texture = 132270,

            form = "bear_form",
            
            handler = function ()
                applyDebuff( "target", "growl" )
            end,
        },
        

        half_moon = {
            id = 274282, 
            known = 274281,
            cast = 2,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = -20,
            spendType = "astral_power",
            
            texture = 1392543,
            startsCombat = true,

            talent = "new_moon",
            bind = "new_moon",
            
            ap_check = function()
                return astral_power.current - action.half_moon.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,
            
            usable = function () return active_moon == 'half_moon' end,
            handler = function ()
                spendCharges( "new_moon", 1 )
                spendCharges( "full_moon", 1 )

                active_moon = "full_moon"
            end,
        },
        

        hibernate = {
            id = 2637,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.15,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136090,
            
            handler = function ()
                applyDebuff( "target", "hibernate" )
            end,
        },
        

        incarnation = {
            id = 102560,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 571586,
            
            handler = function ()
                shift( "moonkin_form" )
                applyBuff( "incarnation" )

                if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
            end,

            copy = "incarnation_chosen_of_elune"
        },
        

        innervate = {
            id = 29166,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            -- toggle = "cooldowns",

            startsCombat = false,
            texture = 136048,
            
            usable = false,
            handler = function ()
                active_dot.innervate = 1
            end,
        },
        

        ironfur = {
            id = 192081,
            cast = 0,
            cooldown = 0.5,
            gcd = "spell",
            
            spend = 45,
            spendType = "rage",
            
            startsCombat = true,
            texture = 1378702,
            
            handler = function ()
                applyBuff( "ironfur" )
            end,
        },
        

        lunar_strike = {
            id = 194153,
            cast = function () 
                if buff.warrior_of_elune.up then return 0 end
                return haste * ( buff.lunar_empowerment.up and 0.85 or 1 ) * 2.25 
            end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( buff.warrior_of_elune.up and 1.4 or 1 ) * -12 end,
            spendType = "astral_power",
            
            startsCombat = true,
            texture = 135753,            

            ap_check = function()
                return astral_power.current - action.lunar_strike.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                removeStack( "lunar_empowerment" )
                removeStack( "warrior_of_elune" )

                if azerite.dawning_sun.enabled then applyBuff( "dawning_sun" ) end
            end,
        },
        

        mangle = {
            id = 33917,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            spend = -8,
            spendType = "rage",

            startsCombat = true,
            texture = 132135,

            talent = "guardian_affinity",
            form = "bear_form",
            
            handler = function ()
            end,
        },
        

        mass_entanglement = {
            id = 102359,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = false,
            texture = 538515,

            talent = "mass_entanglement",
            
            handler = function ()
                applyDebuff( "target", "mass_entanglement" )
                active_dot.mass_entanglement = max( active_dot.mass_entanglement, active_enemies )
            end,
        },
        

        mighty_bash = {
            id = 5211,
            cast = 0,
            cooldown = 50,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132114,

            talent = "mighty_bash",
            
            handler = function ()
                applyDebuff( "target", "mighty_bash" )
            end,
        },
        

        moonfire = {
            id = 8921,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.06,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136096,

            cycle = "moonfire",

            ap_check = function()
                return astral_power.current + 3 + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,                        
            
            handler = function ()
                if not buff.moonkin_form.up and not buff.bear_form.up then unshift() end
                applyDebuff( "target", "moonfire" )
                gain( 3, "astral_power" )
            end,
        },
        

        moonkin_form = {
            id = 24858,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 136036,

            noform = "moonkin_form",
            essential = true,
            
            handler = function ()
                shift( "moonkin_form" )
            end,
        },
        

        new_moon = {
            id = 274281, 
            cast = 1,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",
            
            spend = -10,
            spendType = "astral_power",

            texture = 1392545,
            startsCombat = true,
            
            talent = "new_moon",
            bind = "full_moon",
            
            ap_check = function()
                return astral_power.current - action.new_moon.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
            usable = function () return active_moon == "new_moon" end,
            handler = function ()
                spendCharges( "half_moon", 1 )
                spendCharges( "full_moon", 1 )

                active_moon = "half_moon"
            end,
        },
        

        prowl = {
            id = 5215,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            startsCombat = true,
            texture = 514640,
            
            usable = function () return time == 0 end,
            handler = function ()
                shift( "cat_form" )
                applyBuff( "prowl" )
                removeBuff( "shadowmeld" )
            end,
        },
        

        rake = {
            id = 1822,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 35,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132122,

            talent = "feral_affinity",
            form = "cat_form",
            
            handler = function ()
                applyDebuff( "target", "rake" )
            end,
        },
        

        --[[ rebirth = {
            id = 20484,
            cast = 2,
            cooldown = 600,
            gcd = "spell",
            
            spend = 0,
            spendType = "rage",
            
            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 136080,
            
            handler = function ()
            end,
        }, ]]
        

        regrowth = {
            id = 8936,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.14,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136085,
            
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                applyBuff( "regrowth" )
            end,
        },
        

        rejuvenation = {
            id = 774,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.11,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136081,

            talent = "restoration_affinity",
            
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                applyBuff( "rejuvenation" )
            end,
        },
        

        remove_corruption = {
            id = 2782,
            cast = 0,
            cooldown = 8,
            gcd = "spell",
            
            spend = 0.06,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135952,
            
            handler = function ()
            end,
        },
        

        renewal = {
            id = 108238,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            startsCombat = true,
            texture = 136059,

            talent = "renewal",
            
            handler = function ()
                -- unshift?
                gain( 0.3 * health.max, "health" )
            end,
        },
        

        --[[ revive = {
            id = 50769,
            cast = 10,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.04,
            spendType = "mana",
            
            startsCombat = true,
            texture = 132132,
            
            handler = function ()
            end,
        }, ]]
        

        rip = {
            id = 1079,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 30,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132152,

            talent = "feral_affinity",
            form = "cat_form",

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                spend( combo_points.current, "combo_points" )
                applyDebuff( "target", "rip" )
            end,
        },
        

        shred = {
            id = 5221,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 40,
            spendType = "energy",
            
            startsCombat = true,
            texture = 136231,

            talent = "feral_affinity",
            form = "cat_form",
            
            handler = function ()
                gain( 1, "combo_points" )
            end,
        },
        

        solar_beam = {
            id = 78675,
            cast = 0,
            cooldown = 60,
            gcd = "off",
            
            spend = 0.17,
            spendType = "mana",
            
            toggle = "interrupts",

            startsCombat = true,
            texture = 252188,
            
            usable = function () return target.casting end,
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                interrupt()
            end,
        },
        

        solar_wrath = {
            id = 190984,
            cast = function () return haste * ( buff.solar_empowerment.up and 0.85 or 1 ) * 1.5 end,
            cooldown = 0,
            gcd = "spell",

            spend = -8,
            spendType = "astral_power",
            
            startsCombat = true,
            texture = 535045,
            
            ap_check = function()
                return astral_power.current - action.solar_wrath.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                removeStack( "solar_empowerment" )
                removeBuff( "dawning_sun" )
                if azerite.sunblaze.enabled then applyBuff( "sunblaze" ) end
            end,
        },
        

        soothe = {
            id = 2908,
            cast = 0,
            cooldown = 10,
            gcd = "spell",
            
            spend = 0.06,
            spendType = "mana",
            
            startsCombat = true,
            texture = 132163,
            
            usable = function () return debuff.dispellable_enrage.up end,
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                removeDebuff( "target", "dispellable_enrage" )
            end,
        },
        

        stag_form = {
            id = 210053,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 1394966,

            noform = "travel_form",
            handler = function ()
                shift( "stag_form" )
            end,
        },
        

        starfall = {
            id = 191034,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.oneths_overconfidence.up then return 0 end
                return talent.soul_of_the_forest.enabled and 40 or 50
            end,
            spendType = "astral_power",
            
            startsCombat = true,
            texture = 236168,
            
            ap_check = function()
                return astral_power.current - action.starfall.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
            handler = function ()
                addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
                removeBuff( "oneths_overconfidence" )
                if level < 116 and set_bonus.tier21_4pc == 1 then
                    applyBuff( "solar_solstice" )
                end
            end,
        },
        

        starsurge = {
            id = 78674,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.oneths_intuition.up then return 0 end
                return 40 - ( buff.the_emerald_dreamcatcher.stack * 5 )
            end,
            spendType = "astral_power",
            
            startsCombat = true,
            texture = 135730,
            
            ap_check = function()
                return astral_power.current - action.starsurge.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
            handler = function ()
                addStack( "lunar_empowerment", nil, 1 )
                addStack( "solar_empowerment", nil, 1 )
                addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
                removeBuff( "oneths_intuition" )
                removeBuff( "sunblaze" )

                if pvptalent.moonkin_aura.enabled then
                    addStack( "moonkin_aura", nil, 1 )
                end

                if level < 116 and set_bonus.tier21_4pc == 1 then
                    applyBuff( "solar_solstice" )
                end
                if ( level < 116 and equipped.the_emerald_dreamcatcher ) then addStack( "the_emerald_dreamcatcher", 5, 1 ) end
            end,
        },
        

        stellar_flare = {
            id = 202347,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = -8,
            spendType = "astral_power",
            
            startsCombat = true,
            texture = 1052602,
            cycle = "stellar_flare",

            talent = "stellar_flare",
            
            ap_check = function()
                return astral_power.current - action.stellar_flare.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
            handler = function ()
                applyDebuff( "target", "stellar_flare" )
            end,
        },
        

        sunfire = {
            id = 93402,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.12,
            spendType = "mana",
            
            startsCombat = true,
            texture = 236216,

            cycle = "sunfire",
            
            ap_check = function()
                return astral_power.current - action.sunfire.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
            handler = function ()
                gain( 3, "astral_power" )
                applyDebuff( "target", "sunfire" )
            end,
        },
        

        swiftmend = {
            id = 18562,
            cast = 0,
            charges = 1,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",
            
            spend = 0.14,
            spendType = "mana",
            
            startsCombat = false,
            texture = 134914,

            talent = "restoration_affinity",            
            
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                gain( health.max * 0.1, "health" )
            end,
        },
        
        -- May want to revisit this and split out swipe_cat from swipe_bear.
        swipe = {
            known = 213764,
            cast = 0,
            cooldown = function () return haste * ( buff.cat_form.up and 0 or 6 ) end,
            gcd = "spell",

            spend = function () return buff.cat_form.up and 40 or nil end,
            spendType = function () return buff.cat_form.up and "energy" or nil end,
            
            startsCombat = true,
            texture = 134296,

            talent = "feral_affinity",

            usable = function () return buff.cat_form.up or buff.bear_form.up end,
            handler = function ()
                if buff.cat_form.up then
                    gain( 1, "combo_points" )
                end
            end,

            copy = { 106785, 213771 }
        },
        

        thrash = {
            id = 106832,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -5,
            spendType = "rage",
            
            cycle = "thrash_bear",
            startsCombat = true,
            texture = 451161,

            talent = "guardian_affinity",
            form = "bear_form",
            
            handler = function ()
                applyDebuff( "target", "thrash_bear", nil, debuff.thrash.stack + 1 )
            end,
        },
        

        tiger_dash = {
            id = 252216,
            cast = 0,
            cooldown = 45,
            gcd = "off",
            
            startsCombat = false,
            texture = 1817485,

            talent = "tiger_dash",
            
            handler = function ()
                shift( "cat_form" )
                applyBuff( "tiger_dash" )
            end,
        },
        

        thorns = {
            id = 236696,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            pvptalent = "thorns",
            
            spend = 0.12,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136104,
            
            handler = function ()
                applyBuff( "thorns" )
            end,
        },
        

        travel_form = {
            id = 783,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132144,
            
            noform = "travel_form",
            handler = function ()
                shift( "travel_form" )
            end,
        },
        

        treant_form = {
            id = 114282,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132145,
            
            handler = function ()
                shift( "treant_form" )
            end,
        },
        

        typhoon = {
            id = 132469,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 236170,

            talent = "typhoon",
            
            handler = function ()
                applyDebuff( "target", "typhoon" )
                if target.distance < 15 then setDistance( target.distance + 5 ) end
            end,
        },
        

        warrior_of_elune = {
            id = 202425,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135900,

            talent = "warrior_of_elune",

            usable = function () return buff.warrior_of_elune.down end,
            handler = function ()
                applyBuff( "warrior_of_elune", nil, 3 )
            end,
        },
        

        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1518639,
            
            handler = function ()
            end,
        }, ]]
        

        wild_charge = {
            id = function () return buff.moonkin_form.up and 102383 or 102401 end,
            known = 102401,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            startsCombat = false,
            texture = 538771,

            talent = "wild_charge",
            
            handler = function ()
                if buff.moonkin_form.up then setDistance( target.distance + 10 ) end
            end,

            copy = { 102401, 102383 }
        },
        

        wild_growth = {
            id = 48438,
            cast = 1.5,
            cooldown = 10,
            gcd = "spell",
            
            spend = 0.3,
            spendType = "mana",
            
            startsCombat = false,
            texture = 236153,

            talent = "wild_growth",
            
            handler = function ()
                unshift()
                applyBuff( "wild_growth" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageDots = false,
        damageExpiration = 6,
    
        potion = "potion_of_rising_death",
    
        package = "Balance",        
    } )


    spec:RegisterPack( "Balance", 20190106.2123, [[dGeXMaqiqXJucDjkqTjQkFIQiLrjsDkPIvPKsVckAwufUfvrTlQ8lLOHbk1XOGwgfYZaLmnrsDnLK02Oa6BufjJtjfNtjjwNss18us19av7tjXbPkIfsH6HuGyIkjLlsvKQnsbs6JuGuDsrsyLuL2jfXqPayPua6Pq1uPiDvkqITsbszVK6VIAWQCyulwPEmjtgjxMyZs5ZqPrtv1PbwTij61uuZgXTfXUv1VP0WrQLR45qMUW1bz7qHVlvA8IK05vcwViX8LQ2VK1gQnvJtXHOnXiyB4QaBdHTb6mYqJGLHRQgpwGw040SYmJv04pNiACJzc)krJtZlqSmL2unoYcnkrJ7pcA0QVCjwq4hA7u2KLiqceHdG9vd3ILiqIA5My3l3n2ZucglPhBdqe0sdWigqgqHwAamG5vBGauzJzc)kXHajkn(gcqIuXR3ACkoeTjgbBdxfyBiSnqNrgAeSGTNsJZqHF7OXXbjgenUFafL86TgNsqkn(I1zmt4xj1TAdeGQ8UyD(JGgT6lxIfe(H2oLnzjcKar4ayF1WTyjcKOwUj29YDJ9mLGXs6X2aebT0amIbKbuOLgadyE1giav2yMWVsCiqIQ8UyDE5hINfQZa9OoJGTHRsDEUoJmC1nCvkVL3fRZG4NFScA1lVlwNNRZtOOeQ6WTeEQZyHtCL3fRZZ1zq8ZpwHQUGhSsKbT6umsq1f26ulOiso4bReix5DX68CDEcvQecfcvDOwo4bReO6WGhaVjsDn7uhtrz)6ql8bNQUY7I15568ekkHQodkiPUurijix5DX68CD4GeAcOTqDEskYacPUyyquhXAndrJQlnL990I6GqsDq)lkbH4zH6WGhaVjsDOf(Gt1oonobGcK2unoL0yisOnvBIHAt14Ska2xJJSeEYBHt04YZBIqPnwhAtmsBQgxEEtekTXAC1aczaSgFd1AofNbVYbrRXzvaSVgN2ga7RdTjWsBQgxEEtekTXAC1aczaSgFd1AofNbVYbrRXzvaSVgFtSwQCdAwqhAtsT2unU88MiuAJ14QbeYayn(gQ1CkodELdIwJZQayFn(wgKmMbpwDOnzv1MQXLN3eHsBSgxnGqgaRX3qTMtXzWRCq0ACwfa7RX5rXVKd7mYh6qBIbQnvJlpVjcL2ynUAaHmawJVHAnNIZGx5GO14Ska2xJtay9hOCQeIcBI8Ho0M4P0MQXLN3eHsBSgxnGqgaRX3qTMtXzWRCq0ACwfa7RXBGr2eRLshAtwJ2unU88MiuAJ14QbeYayn(gQ1CkodELdIwJZQayFno)kbfdtYkMq0H2KvrBQgxEEtekTXAC1aczaSgxzTekB33P4m4vUrsyWJQBL6GfS14Ska2xJdHKmiKeKo0MyiS1MQXzvaSVgVlpdWozBlleOx04YZBIqPnwhAtm0qTPAC55nrO0gRXvdiKbWACofzaH4iameYczenyaHtEEteQ68vx66uwlHY29DGxXZZbW(UrsyWJQB96mQU((6uwlHY29DkHiOaWKmtay)e5d3ijm4r1TEDgAuDD04Ska2xJd(xgm4q0H2ednsBQgxEEtekTXAC1aczaSgNrXWKmTTRm1Tc86snS14Ska2xJdEfppha7RdTjgclTPAC55nrO0gRXvdiKbWACgfdtY02UYu3kWRl1WUoF1LUoyQJtrgqiocadHSqgrdgq4KN3eHQU((62qTMJaWqilKr0Gbeoi666uNV6sx3gQ1COGhIDOCOGvMRBf41zuD991btDbtKpCOGhIDOCYZBIqvxFFDWuhNImGqCOye2m4XMrbpiN88Miu11rJZQayFnUsickamjZea2pr(qhAtmm1At14YZBIqPnwJRgqidG14PRBd1AofNbVYbrxxFFDkRLqz7(ofNbVYnscdEuDRuhSGDDDQZxDilHNC3Hd)oMoR8lkZACwfa7RXBqZczBlleOx0H2edxvTPAC55nrO0gRXvdiKbWA801THAnNIZGx5GORRVVoL1sOSDFNIZGx5gjHbpQUvQdwWUUo15RoMoR8lkZACwfa7RXB2rjzBl)CanIo0MyObQnvJlpVjcL2ynUAaHmawJVHAnhk4Hyhk3ijm4r1TEDRPoF1btDilHNC3Hd)oMoR8lkZACwfa7RXv8ResEd1AA8nuRLFor04OGhIDO0H2ed9uAt14YZBIqPnwJRgqidG14PRBd1AouWdXououWkZ1TEDWQU((62qTMdf8qSdLBKeg8O6wbEDRPUo15RoeTqi5GhSsGQBf41HbpaEtehQLdEWkbQoF1LUUGhSs4cqIKdBMci1HzDgwxN6wBDiAHqYbpyLav3k1PSOOodUoJCRQgNvbW(ACuWtJjeDOnXW1OnvJlpVjcL2ynUAaHmawJNUUGjYhouWdXouo55nrOQZxDPRBd1AouWdXououWkZ1TEDWQU((62qTMdf8qSdLBKeg8O6wbEDRPoF1THAnhpk(bQmnebXJdfSYCDRx3AQRtD991btDbtKpCOGhIDOCYZBIqvNV6sx3gQ1C8O4hOY0qeepouWkZ1TEDRPU((62qTMtXzWRCq011PUo15RoeTqi5GhSsGCOGNgti1TEDyWdG3eXHA5GhSsGQZxDBOwZrGEEYscTTRmjYhouWkZ1HzDBOwZHSeEYscTTRmjYhouWkZ1TEDPUoF1THAnhYs4jlj02UYKiF4qbRmx361bR68v3gQ1CeONNSKqB7ktI8HdfSYCDRxhSQZxDPRdM64uKbeIdfJWMbp2mk4b5KN3eHQU((6GPUnuR5uCg8kheDD991btD0JGHdf8GGgSsDDQRVVUGhSs4cqIKdBMci1To86KuvuqHKdqIu3ARJrXWKmTTRm1zW1LAyxxFFDWuhYs4j3D4WVJPZk)IYSgNvbW(ACuWdcAWk6qBIHRI2unU88MiuAJ14Ska2xJJG(gyenUAaHmawJpsBeKFEtK68vx66y6SYVOmxNV6AeRDQlDDbpyLWfGejh2mfqQZGRlDDgv3ARdrles2pJcPUo11PU1whIwiKCWdwjq1Tc86sDDywhIwiKCWdwjq15RU01HOfcjh8GvcuDRuNH1HzDbtKpCrxWNtS2h5KN3eHQU((6OSHlXA)gyexauMbp266uNV6sxhm1XPidiehkgHndESzuWdYjpVjcvD991btDBOwZP4m4voi6667RdM6Ohbdhc6BGrQRtDD04Qfuejh8GvcK2ed1H2eJGT2unU88MiuAJ14Ska2xJNyTFdmIgxnGqgaRXhPncYpVjsD(QlDDmDw5xuMRZxDnI1o1LUUGhSs4cqIKdBMci1zW1LUoJQBT1HOfcj7NrHuxN66u3ARdrleso4bReO6wbEDgyD(QlDDWuhNImGqCOye2m4XMrbpiN88Miu113xhm1THAnNIZGx5GORRVVoyQJEemCjw73aJuxN66OXvlOiso4bReiTjgQdTjgzO2unU88MiuAJ14Ska2xJJcHq4j3i8iAC1aczaSgFK2ii)8Mi15RU01X0zLFrzUoF11iw7ux66cEWkHlajsoSzkGuNbxx66mQU1whIwiKSFgfsDDQRtDRaVodSoF1LUoyQJtrgqioumcBg8yZOGhKtEEteQ667RdM62qTMtXzWRCq0113xhm1rpcgouiecp5gHhPUo11rJRwqrKCWdwjqAtmuhAtmYiTPAC55nrO0gRXvdiKbWACMoR8lkZACwfa7RXFPBoXAFDOnXiyPnvJlpVjcL2ynUAaHmawJZ0zLFrzwJZQayFnUFM0Yjw7RdTjgLATPAC55nrO0gRXvdiKbWACMoR8lkZACwfa7RXBqesoXAFDOnXOvvBQgxEEtekTXAC1aczaSgFd1AoKLWtwsOTDLjr(WHcwzUU1Rdw15RU01X0zLFrzUU((62qTMJa98KLeABxzsKpCOGvMRdEDWQUo15RU01LUUnuR56YZaSt22Ycb6fheDD991THAnhb65jlj02UYKiF4GORRVVoeTqi5GhSsGQBf41zuD(QdM62qTMdzj8KLeABxzsKpCq0113xhNImGqCuC3h8yZiO3jpVjcvD(QdM62qTMJI7(GhBgb9oi666uNV6sxhm1XPidiehkgHndESzuWdYjpVjcvD991btDBOwZP4m4voi6667RlDDWuh9iy4iqppzumaZsD(QdM6cMiF4aVINNdG9DYZBIqvxFFD0JGHdzj8K7oC4VUo11PU((64uKbeIdfJWMbp2mk4b5KN3eHQoF1THAnNIZGx5GORZxD0JGHdzj8K7oC4VUoACwfa7RXjqppzumaZIo0MyKbQnvJlpVjcL2ynUAaHmawJZPidiehkgHndESzuWdYn8BUU1Rdw113xhm1THAnNIZGx5GORRVVoyQJEemCilHNC3Hd)ACwfa7RXrwcp5Udh(1H2eJ8uAt14Ska2xJJG(gyenU88MiuAJ1Ho040JOSjBo0MQnXqTPAC55nrO0gRdTjgPnvJlpVjcL2yDOnbwAt14YZBIqPnwhAtsT2unU88MiuAJ14wAnoscnoRcG914yWdG3erJJbtGenEQRdZ6sxxWe5dx0f85eR9ro55nrOQZxDPRJtrgqioEu8duzAicIhN88Miu113xxWe5dhk4HyhkN88Miu11PUo1556sxhm1XPidiehpk(bQmnebXJtEEteQ68vhm1fmr(WHcEi2HYjpVjcvD(QlyI8HdfcHWtMAaTWjpVjcvDD04yWt(5erJJA5GhSsG0H2KvvBQgNvbW(A8eR9nd(CZojAC55nrO0gRdTjgO2unU88MiuAJ1H2epL2unoRcG91402ayFnU88MiuAJ1H2K1OnvJZQayFnoYs4j3D4WVgxEEtekTX6qh6qJJHmiG91MyeSnCngAeSGTZidn0inExEEWJfPXtfj02jeQ6mQowfa7xhbGcKR8QXPhBdqen(I1zmt4xj1TAdeGQ8UyD(JGgT6lxIfe(H2oLnzjcKar4ayF1WTyjcKOwUj29YDJ9mLGXs6X2aebT0amIbKbuOLgadyE1giav2yMWVsCiqIQ8UyDE5hINfQZa9OoJGTHRsDEUoJmC1nCvkVL3fRZG4NFScA1lVlwNNRZtOOeQ6WTeEQZyHtCL3fRZZ1zq8ZpwHQUGhSsKbT6umsq1f26ulOiso4bReix5DX68CDEcvQecfcvDOwo4bReO6WGhaVjsDn7uhtrz)6ql8bNQUY7I15568ekkHQodkiPUurijix5DX68CD4GeAcOTqDEskYacPUyyquhXAndrJQlnL990I6GqsDq)lkbH4zH6WGhaVjsDOf(Gt1oUYB5DX680tvrbfcvDBPzhPoLnzZrDBbl4rU68eLsOduDV99SFEsAqK6yvaSpQo7twWvEzvaSpYrpIYMS5aEJWiZLxwfa7JC0JOSjBoWe(YM1svEzvaSpYrpIYMS5at4lziSjYhCaSF5DX68KuKbesDg04bWBIGkVlwhRcG9ro6ru2KnhycFjg8a4nr845eboNsgH8adMajW5uKbeIdfJWMbp2mk4b5g(nxExSowfa7JC0JOSjBoWe(sm4bWBI4XZjcCoLmfYdmycKaNtrgqiokU7dESze07g(nxExSowfa7JC0JOSjBoWe(sm4bWBI4XZjcCoLmt7bgmbsGZPidiehpk(bQmnebXJB43C5DX6WdEAmHuhg1Hh8GGgSsDbpyLOofuyBTYlRcG9ro6ru2KnhycFjg8a4nr845eboQLdEWkbYdlnCKeEGbtGe4PgZ0btKpCrxWNtS2h5KN3eHYxAofzaH44rXpqLPHiiECYZBIq13hmr(WHcEi2HYjpVjcvNoEonmCkYacXXJIFGktdrq84KN3eHYhmbtKpCOGhIDOCYZBIq5lyI8HdfcHWtMAaTWjpVjcvNYlRcG9ro6ru2KnhycFzI1(MbFUzNKY7I1H)mnYVnQByavDBOwtOQdfCGQBln7i1PSjBoQBlybpQo(PQJEeptBJa8yRdGQJY(IR8YQayFKJEeLnzZbMWxIEMg53gzuWbQ8YQayFKJEeLnzZbMWxsBdG9lVSka2h5Ohrzt2CGj8LilHNC3Hd)L3Y7I15PNQIckeQ6emKzH6cqIux4xQJvHDQdGQJXGbeEtex5LvbW(i4ilHN8w4KYlRcG9rycFjTna23dqd(gQ1CkodELdIU8YQayFeMWxUjwlvUbnl4bObFd1AofNbVYbrxEzvaSpct4l3YGKXm4X6bObFd1AofNbVYbrxEzvaSpct4l5rXVKd7mYhEaAW3qTMtXzWRCq0Lxwfa7JWe(scaR)aLtLquytKp8a0GVHAnNIZGx5GOlVSka2hHj8LnWiBI1s5bObFd1AofNbVYbrxEzvaSpct4l5xjOyyswXeIhGg8nuR5uCg8kheD5T8UyDgKvdvEzvaSpct4lHqsgescYdqdUYAju2UVtXzWRCJKWGhTcSGD5LvbW(imHVSlpdWozBlleOxkVSka2hHj8LG)Lbdoepan4CkYacXrayiKfYiAWacN88Miu(sRSwcLT77aVINNdG9DJKWGhTUr99kRLqz7(oLqeuaysMjaSFI8HBKeg8O1n0OoLxwfa7JWe(sWR455ayFpan4mkgMKPTDLzf4Pg2Lxwfa7JWe(sLqeuaysMjaSFI8HhGgCgfdtY02UYSc8udBFPHHtrgqiocadHSqgrdgq4KN3eHQVFd1AocadHSqgrdgq4GO74l9gQ1COGhIDOCOGvMxbUr99Wemr(WHcEi2HYjpVjcvFpmCkYacXHIryZGhBgf8GCYZBIq1P8YQayFeMWx2GMfY2wwiqV4bObp9gQ1CkodELdIUVxzTekB33P4m4vUrsyWJwbwWUJpKLWtU7WHFhtNv(fL5YlRcG9rycFzZokjBB5NdOr8a0GNEd1AofNbVYbr33RSwcLT77uCg8k3ijm4rRaly3XhtNv(fL5YB5DX6WPLNsgu5LvbW(imHVuXVsi5nuR5XZjcCuWdXouEaAW3qTMdf8qSdLBKeg8O1xJpyqwcp5Udh(DmDw5xuMlVSka2hHj8LOGNgtiEaAWtVHAnhk4HyhkhkyL51HvF)gQ1COGhIDOCJKWGhTc810XhIwiKCWdwjqRahdEa8Mioulh8GvcKV0bpyLWfGejh2mfqW0WoRfrleso4bReOvuwuyWg5w1YlRcG9rycFjk4bbnyfpan4PdMiF4qbpe7q5KN3eHYx6nuR5qbpe7q5qbRmVoS673qTMdf8qSdLBKeg8OvGVgFBOwZXJIFGktdrq84qbRmV(A603dtWe5dhk4HyhkN88Miu(sVHAnhpk(bQmnebXJdfSY86RPVFd1AofNbVYbr3PJpeTqi5GhSsGCOGNgtiRJbpaEtehQLdEWkbY3gQ1CeONNSKqB7ktI8HdfSYmMBOwZHSeEYscTTRmjYhouWkZRNAFBOwZHSeEYscTTRmjYhouWkZRdlFBOwZrGEEYscTTRmjYhouWkZRdlFPHHtrgqioumcBg8yZOGhKtEEteQ(Ey2qTMtXzWRCq099WqpcgouWdcAWkD67dEWkHlajsoSzkGSoCjvffui5aKiRLrXWKmTTRmgCQHDFpmilHNC3Hd)oMoR8lkZL3Y7I1TAwtrLxwfa7JWe(se03aJ4HAbfrYbpyLab3qpan4J0gb5N3eXxAMoR8lkZ(AeRDsh8GvcxasKCyZuaXGtB0Ar0cHK9ZOq60zTiAHqYbpyLaTc8uJjIwiKCWdwjq(sJOfcjh8Gvc0kgIzWe5dx0f85eR9ro55nrO67PSHlXA)gyexauMbp2o(sddNImGqCOye2m4XMrbpiN88Miu99WSHAnNIZGx5GO77HHEemCiOVbgPtNYlRcG9rycFzI1(nWiEOwqrKCWdwjqWn0dqd(iTrq(5nr8LMPZk)IYSVgXAN0bpyLWfGejh2mfqm40gTweTqiz)mkKoDwlIwiKCWdwjqRa3a9LggofzaH4qXiSzWJnJcEqo55nrO67Hzd1AofNbVYbr33dd9iy4sS2VbgPtNYlRcG9rycFjkecHNCJWJ4HAbfrYbpyLab3qpan4J0gb5N3eXxAMoR8lkZ(AeRDsh8GvcxasKCyZuaXGtB0Ar0cHK9ZOq60zf4gOV0WWPidiehkgHndESzuWdYjpVjcvFpmBOwZP4m4voi6(EyOhbdhkecHNCJWJ0Pt5T8UyDg0LxgoSdQ8YQayFeMWx(s3CI1(EaAWz6SYVOmxEzvaSpct4l9ZKwoXAFpan4mDw5xuMlVSka2hHj8LnicjNyTVhGgCMoR8lkZLxwfa7JWe(sc0ZtgfdWS4bObFd1AoKLWtwsOTDLjr(WHcwzEDy5lntNv(fL5((nuR5iqppzjH22vMe5dhkyLz4WQJV0P3qTMRlpdWozBlleOxCq099BOwZrGEEYscTTRmjYhoi6(EeTqi5GhSsGwbUr(Gzd1AoKLWtwsOTDLjr(Wbr33ZPidiehf39bp2mc6DYZBIq5dMnuR5O4Up4XMrqVdIUJV0WWPidiehkgHndESzuWdYjpVjcvFpmBOwZP4m4voi6((0Wqpcgoc0ZtgfdWS4dMGjYhoWR455ayFN88Miu990JGHdzj8K7oC4VtN(EofzaH4qXiSzWJnJcEqo55nrO8THAnNIZGx5GO9rpcgoKLWtU7WH)oLxwfa7JWe(sKLWtU7WHFpan4CkYacXHIryZGhBgf8GCd)Mxhw99WSHAnNIZGx5GO77HHEemCilHNC3Hd)L3Y7I1zqLjKW)avxZo1LyXqsKpkVSka2hHj8LiOVbgrJJOfL2edHTr6qhAn]] )

    
end