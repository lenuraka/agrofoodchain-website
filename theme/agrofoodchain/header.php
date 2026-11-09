<?php if (!defined('ABSPATH')) { exit; } ?>
<!doctype html><html <?php language_attributes(); ?>><head><meta charset="<?php bloginfo('charset'); ?>"><meta name="viewport" content="width=device-width, initial-scale=1"><?php wp_head(); ?></head>
<body <?php body_class(); ?>><?php wp_body_open(); ?><a class="skip-link" href="#main-content">Skip to content</a>
<div class="topbar"><div class="wrap topbar-inner"><span>Expertise for sustainable agriculture, food systems and responsible supply chains across Central Asia</span><span>Regional expertise · International standards</span></div></div>
<header class="site-header" id="top"><div class="wrap header-inner">
<a class="brand" href="<?php echo esc_url(home_url('/')); ?>" aria-label="AGRO FOOD CHAIN — Home">
<?php if (has_custom_logo()): echo wp_get_attachment_image(get_theme_mod('custom_logo'),'full',false,array('class'=>'brand-logo','alt'=>'AGRO FOOD CHAIN')); else: ?>
<img class="brand-logo" src="<?php echo esc_url(get_template_directory_uri().'/assets/images/agro-food-chain-logo.png'); ?>" alt="AGRO FOOD CHAIN">
<?php endif; ?></a>
<button class="menu-toggle" type="button" aria-expanded="false" aria-controls="site-navigation" aria-label="Toggle navigation"><span></span><span></span><span></span></button>
<nav id="site-navigation" class="site-nav" aria-label="Main navigation"><?php wp_nav_menu(array('theme_location'=>'primary','container'=>false,'menu_class'=>'nav-list','menu_id'=>'primary-menu','fallback_cb'=>'afc_nav_fallback','depth'=>1)); ?></nav>
<a class="header-contact" href="<?php echo esc_url(home_url('/contact/')); ?>">Get a Quote <span aria-hidden="true">↗</span></a>
</div></header>
