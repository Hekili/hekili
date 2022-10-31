actions.precombat+=/mark_of_the_wild,if=!up&!buff.gift_of_the_wild.up
actions.precombat+=/cat_form,if=!up

actions+=/use_items
actions+=/run_action_list,name=bear,if=buff.dire_bear_form.up
actions+=/run_action_list,name=cat_aoe,if=buff.cat_form.up&active_enemies>1
actions+=/run_action_list,name=cat,if=buff.cat_form.up
actions+=/cat_form,if=!up

actions.cat+=/dire_bear_form,if=debuff.lacerate.up&debuff.lacerate.remains<4&debuff.rip.remains>4
actions.cat+=/shred,if=buff.clearcasting.up
actions.cat+=/tigers_fury,if=energy.current<30
actions.cat+=/berserk,if=cooldown.tigers_fury.remains>15
actions.cat+=/wait,sec=debuff.rip.remains,if=debuff.rip.remains<energy.time_to_max&combo_points.current=5&!buff.berserk.up&(!debuff.lacerate.up|debuff.lacerate.remains>=debuff.rip.remains+4)
actions.cat+=/rip,if=(!up|debuff.rip.remains<4)&combo_points.current=5
actions.cat+=/savage_roar,if=(debuff.rip.up&buff.savage_roar.up&buff.savage_roar.remains-debuff.rip.remains<0&debuff.rip.remains+((debuff.rip.remains<9&2)|10)<14+((combo_points.current-1)*5))|(debuff.rip.up&remains<4&((combo_points.current<4&debuff.rip.remains>10)|(combo_points.current=4&debuff.rip.remains>13)|(combo_points.current=5&debuff.rip.remains>16)))|(!debuff.rip.up&!up&combo_points.current<4)
actions.cat+=/mangle_cat,if=!debuff.mangle.up
actions.cat+=/rake,if=!up&energy.current=100&combo_points.current<5
actions.cat+=/shred,if=energy.current=100&combo_points.current<5
actions.cat+=/ferocious_bite,if=((debuff.rip.remains>=12&buff.savage_roar.remains>=10)|(buff.berserk.up&debuff.rip.remains>=10&buff.savage_roar.remains>=8))&combo_points.current=5
actions.cat+=/dire_bear_form,if=!buff.berserk.up&cooldown.tigers_fury.remains>6&debuff.rip.remains>8&buff.savage_roar.remains>6&energy.current<40
actions.cat+=/rake,if=!up|debuff.rake.remains<0.8
actions.cat+=/faerie_fire_feral,if=!debuff.armor_reduction.up&!buff.berserk.up
actions.cat+=/shred

actions.cat_aoe+=/tigers_fury,if=energy.current<30
actions.cat_aoe+=/berserk,if=cooldown.tigers_fury.remains>15
actions.cat_aoe+=/rake,if=!up&!buff.savage_roar.up&!buff.clearcasting.up
actions.cat_aoe+=/savage_roar,if=!up
actions.cat_aoe+=/swipe_cat
actions.cat_aoe+=/gift_of_the_wild,if=energy.current<45&(encounterDifficulty>=3&encounterDifficulty<=6)

actions.bear+=/lacerate,if=up&remains<10
actions.bear+=/cat_form,if=energy.current>=68|(debuff.rip.remains<=4&buff.savage_roar.remains>debuff.rip.remains&combo_points.current<5)|(buff.clearcasting.up&combo_points<5)|buff.berserk.up
actions.bear+=/lacerate,if=debuff.lacerate.stack<5
actions.bear+=/maul,if=rage.current>=25