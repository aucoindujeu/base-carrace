-- **********************************
-- Variables utilisées dans le jeu
-- *********************************

-- Constantes
LARGEUR_ECRAN = 400
HAUTEUR_ECRAN = 600
VY_MAX = 8
FREQ_ENNEMIS = 30
DELAI = 3
CHRONO = 60

etatJeu = 'menu'


-- Sprite Joueur
joueureuse = {}
joueureuse.img = love.graphics.newImage('images/joueureuse.png')
joueureuse.imgExplosion = love.graphics.newImage('images/explosion.png')
joueureuse.l = joueureuse.img:getWidth()
joueureuse.h = joueureuse.img:getHeight()
joueureuse.x = 0 
joueureuse.y = 0 
joueureuse.y_ini = HAUTEUR_ECRAN - joueureuse.h * 2
joueureuse.y_max = joueureuse.h * 2
joueureuse.vx = 100
joueureuse.vy = 0 
joueureuse.acceleration = 5
joueureuse.touche = false
joueureuse.delai = DELAI
joueureuse.chrono = CHRONO
joueureuse.touche = false
joueureuse.score = 0

-- Sprites Ennemis
lstEnnemis = {}
chronoEnnemis = FREQ_ENNEMIS 

-- Scrolling
scrolling = {}
scrolling.camera = 0
scrolling.imgFond = love.graphics.newImage('images/fond.png')
scrolling.imgBandes = love.graphics.newImage('images/bandes.png')
scrolling.xBandes = (scrolling.imgFond:getWidth() - scrolling.imgBandes:getWidth()) / 2
scrolling.h = scrolling.imgBandes:getHeight()

-- *****************
-- Fonctions
-- *****************

-- test collision méthode bounding boxes
function testeCollision(pX1, pY1, pL1, pH1, pX2, pY2, pL2, pH2)

  return pX1 < pX2 + pL2 and pX2 < pX1 + pL1 and pY1 < pY2 + pH2 and pY2 < pY1 + pH1

end

function creerEnnemi()

  local ennemi = {}
  ennemi.x = pX
  ennemi.vy = math.random(50, 300) 
  ennemi.img = love.graphics.newImage('images/ennemi.png')
  ennemi.imgExplosion = love.graphics.newImage('images/explosion.png')
  ennemi.l = ennemi.img:getWidth()
  ennemi.h = ennemi.img:getHeight()
  ennemi.y = 0 - ennemi.h
  ennemi.touche = false

  ennemi.x = math.random(100, 300 - ennemi.l)

  return ennemi

end


-- ****************************
-- INITIALISATION DE LA PARTIE
-- ****************************

function initJeu()
  
  joueureuse.x = (LARGEUR_ECRAN - joueureuse.l)/2
  joueureuse.y = joueureuse.y_ini
  joueureuse.touche = false
  joueureuse.vy = 0 
  joueureuse.score = 0
  joueureuse.delai = DELAI
  joueureuse.chrono = CHRONO 

  lstEnnemis = {}

end


function love.load()

  love.window.setMode(LARGEUR_ECRAN, HAUTEUR_ECRAN)
  love.window.setTitle('Car Race - Code Club CimeLab - Au Coin du jeu')
  
  police = love.graphics.newFont('fontes/police.ttf', 10)
  love.graphics.setFont(police)

  initJeu()

end


-- ******************
-- MISE À JOUR JEU (update)
-- ******************

function majMenu()

end


function majJoueureuse(dt)

  joueureuse.chrono = joueureuse.chrono - dt
  if joueureuse.chrono <= 0 then
    joueureuse.score = joueureuse.score + 20
    etatJeu = "game over"
  end

  if joueureuse.touche == false then
    if love.keyboard.isDown('left') then
      joueureuse.x = joueureuse.x - (joueureuse.vx + 10 * math.abs(joueureuse.vy)) * dt
    end

    if love.keyboard.isDown('right') then
      joueureuse.x = joueureuse.x + (joueureuse.vx + 10 * math.abs(joueureuse.vy)) * dt
    end

    if joueureuse.x < 100 or joueureuse.x + joueureuse.l > 300 then
      joueureuse.touche = true
    end

    
    if (joueureuse.y <= joueureuse.y_ini and joueureuse.y >= joueureuse.y_max) then
      if love.keyboard.isDown('up') then
        joueureuse.vy = joueureuse.vy + joueureuse.acceleration * dt
        if joueureuse.vy > VY_MAX then
          joueureuse.vy = VY_MAX
        end
      else
        if joueureuse.y < joueureuse.y_ini then
          joueureuse.vy = joueureuse.vy - joueureuse.acceleration * dt
        end
      end
    
      joueureuse.y = joueureuse.y - joueureuse.vy
    end
    
    if joueureuse.y > joueureuse.y_ini then
      joueureuse.y = joueureuse.y_ini
      joueureuse.vy = 0
    end

    if joueureuse.y < joueureuse.y_max then
      joueureuse.y = joueureuse.y_max
    end

  else 
    
    if joueureuse.delai > 0 then
      joueureuse.delai = joueureuse.delai - dt
    else
      etatJeu = 'game over'
    end
  end

end


function majEnnemis(dt, pVit)

  chronoEnnemis = chronoEnnemis - pVit * dt
  if chronoEnnemis < 0 then
    chronoEnnemis = FREQ_ENNEMIS - math.random(15)
    table.insert(lstEnnemis, creerEnnemi())
  end
  
  for n = #lstEnnemis, 1, -1 do

    local ennemi = lstEnnemis[n]
    if ennemi.touche == false then

      ennemi.y = ennemi.y - ennemi.vy * dt + pVit /2
      if ennemi.y > HAUTEUR_ECRAN then
        table.remove(lstEnnemis, n)
        joueureuse.score = joueureuse.score + 1
      end

      if testeCollision(ennemi.x, 
                        ennemi.y, 
                        ennemi.l, 
                        ennemi.h, 
                        joueureuse.x,
                        joueureuse.y,
                        joueureuse.l,
                        joueureuse.h) then
        joueureuse.touche = true
        ennemi.touche = true
      end
    end

  end

end


function love.update(dt)
  
  if etatJeu == 'menu' then

    majMenu()

  elseif etatJeu == 'en jeu' then

    scrl = ((600 - joueureuse.y)^2/200 + 600) * dt
    scrolling.camera = scrolling.camera + scrl
    if scrolling.camera >= scrolling.h then
      scrolling.camera = 0
    end

    majJoueureuse(dt) 

    majEnnemis(dt, scrl)
  
  end

end

-- ***************
-- AFFICHAGE
-- ***************

function texteCentre(pTexte, pHauteur)

  love.graphics.printf(pTexte, 0, pHauteur, LARGEUR_ECRAN, 'center')

end


function afficheMenu()

  texteCentre('appuyer sur `espace` pour lancer le jeu', HAUTEUR_ECRAN/2)

end


function afficheJoueur()

  local img = nil

  if joueureuse.touche == false then
    img = joueureuse.img
  else
    img = joueureuse.imgExplosion
  end

  love.graphics.draw(img, joueureuse.x, joueureuse.y)

end


function afficheEnnemis()

  for n = #lstEnnemis, 1, -1 do
    ennemi = lstEnnemis[n]
    local img = nil
    if ennemi.touche == false then
      img = ennemi.img
    else
      img = ennemi.imgExplosion
    end
    love.graphics.draw(img, ennemi.x, ennemi.y)
  end

end


function afficheGameOver()

  if joueureuse.touche == true then
    texteCentre('Game over', HAUTEUR_ECRAN/2 - 40)
  elseif joueureuse.chrono <= 0 then
    texteCentre('Bravo ! Bonus de 20 points', HAUTEUR_ECRAN/2 - 40)
  end

  texteCentre('Votre score est de '..tostring(joueureuse.score), HAUTEUR_ECRAN/2)
  texteCentre('Appuyer sur entrée pour revenir au menu', HAUTEUR_ECRAN/2 + 40)

end


function love.draw()

  if etatJeu == 'menu' then
    
    afficheMenu()

  elseif etatJeu == 'en jeu' then

    -- affichage fond/scrolling
    love.graphics.draw(scrolling.imgFond, 0, 0)
    love.graphics.draw(scrolling.imgBandes, scrolling.xBandes, scrolling.camera - scrolling.h)
    love.graphics.draw(scrolling.imgBandes, scrolling.xBandes, scrolling.camera)

    afficheJoueur()
    afficheEnnemis()

    --score et chrono
    love.graphics.print('Temps : '..tostring(math.ceil(joueureuse.chrono)), 10, 10)
    love.graphics.print('Score : '..tostring(joueureuse.score), 10, 30)

  elseif etatJeu == 'game over' then

    afficheGameOver()

  end

end

--*******************
-- TOUCHES HORS-JEU
-- ******************

function love.keypressed(key)

  if key == 'escape' then
    love.event.quit()
  end

  if key== 'space' and etatJeu == 'menu' then
    etatJeu = 'en jeu'
    initJeu()
  end

  if key == 'return' and etatJeu == 'game over' then
    etatJeu = 'menu'
  end

end
