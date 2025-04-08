Config = {}

-- Genel Debug Logları Aktif/Pasif
Config.EnableDebugLogs = false    -- true yaparsanız [DEBUG] logları konsolda görünür.

-- Framework Ayarı ('qbcore', 'esx', 'standalone') -- DİKKAT: Burayı sunucunuza göre ayarlayın!
Config.Framework = 'qbcore'

-- Genel Ayarlar
Config.EnableOOC = true           -- /ooc komutu aktif mi?
Config.AllowNormalChat = false    -- Komut olmadan mesaj gönderilebilir mi?
Config.AdminGroupName = 'admin'   -- Duyuru komutu için KULLANILACAK GRUP/YETKİ ADI (örn: 'admin', 'superadmin', 'god') - Burayı kendi frameworkünüze göre değiştirin!

-- Komut Prefixleriimage.png
Config.OOCPrefix = "[OOC]"
Config.MePrefix = "[ME]"
Config.DoPrefix = "[DO]"
Config.DefaultPrefix = "" -- Komutsuz mesajlar için (AllowNormalChat = true ise)
Config.PmHataPrefix = "[HATA]" -- Hata mesajları için kalabilir

-- Küfür Filtresi Ayarları
Config.EnableProfanityFilter = true -- Küfür filtresi aktif mi?
Config.BlockedWords = {"test"}
Config.ProfanityReplacement = "***" -- Engellenen kelime yerine ne yazılsın?

-- Mesaj Uzunluk Limiti
Config.MaxMessageLength = 128 -- Maksimum mesaj uzunluğu (0 = limitsiz)

-- Kafa Üstü 3D Yazı (/me, /do için)
Config.EnableHeadUI = true       -- Bu özellik aktif mi?
Config.HeadUIDuration = 7000      -- Yazının ekranda kalma süresi (milisaniye)
Config.HeadUIDistance = 15.0      -- Yazının görünme mesafesi (oyun birimi)
Config.HeadUIOffsetY = 0.9        -- Yazının oyuncunun kafasına göre Y eksenindeki ofseti (En alttaki yazı için)
Config.HeadUITextSize = 0.35      -- 3D Yazı boyutu
Config.HeadUITextFont = 0         -- 3D Yazı fontu (0: Genellikle daha iyi Türkçe karakter desteği)
Config.HeadUIMaxLines = 3         -- Kafa üstünde aynı anda görünecek maksimum satır sayısı
Config.HeadUIAlphaDecay = 0.6     -- Önceki satırların opaklık azalma oranı (0.0 - 1.0)
Config.HeadUILineSpacing = 0.09   -- Satırlar arasındaki dikey boşluk

-- Renkler (RGBA formatında veya CSS renk isimleri - JS tarafında kullanılacak)
Config.Colors = {
    default = "#FFFFFF", -- Beyaz (Normal mesaj)
    ooc = "#D3D3D3",     -- Açık Gri (OOC)
    me = "#C1A4E0",      -- Mor (Me - Chat Log Rengi)
    doCmd = "#A4D4E0",    -- Açık Mavi (Do Komutu - Chat Log Rengi)
    mention = "#FFFF00",  -- Sarı (Etiketleme)
    error = "#FF0000",   -- Kırmızı (Hata)
    admin = "#FF4500",  -- Admin/Duyuru rengi

    -- 3D Yazı Renkleri (RGB 0-255 formatında)
    headUIMe = { r = 210, g = 180, b = 230 }, -- Açık Mor Me
    headUIDo = { r = 255, g = 165, b = 0 }  -- Turuncu Do
} 