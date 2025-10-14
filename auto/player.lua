vanilla_model.CAPE:setVisible(false)
vanilla_model.ELYTRA:setVisible(false)
vanilla_model.PLAYER:setVisible(false)

local player = models.player

player.Base.Torso.Body.Cape:setPrimaryTexture("CAPE")
player.Base.Torso.Body.RightElytra:setPrimaryTexture("CAPE"):scale(1.1,1.1,2.4)
player.Base.Torso.Body.LeftElytra:setPrimaryTexture("CAPE"):scale(1.1,1.1,2.4)
player:setPrimaryRenderType("CUTOUT_CULL")

--models.player:setPrimaryTexture("SKIN")
--animations.player.california:play()

animations.player.HatGirlDance:speed(0.7)

models.accessories.sword:setVisible(false)