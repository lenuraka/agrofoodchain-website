<?php
/** AGRO FOOD CHAIN — setup and theme helpers. */
if (!defined('ABSPATH')) { exit; }

function afc_theme_setup() {
    load_theme_textdomain('agrofoodchain', get_template_directory() . '/languages');
    add_theme_support('title-tag');
    add_theme_support('post-thumbnails');
    add_theme_support('automatic-feed-links');
    add_theme_support('html5', array('search-form', 'gallery', 'caption', 'style', 'script'));
    add_theme_support('custom-logo', array('height' => 100, 'width' => 340, 'flex-height' => true, 'flex-width' => true));
    register_nav_menus(array('primary' => __('Primary navigation', 'agrofoodchain'), 'footer' => __('Footer navigation', 'agrofoodchain')));
}
add_action('after_setup_theme', 'afc_theme_setup');

function afc_assets() {
    $v = wp_get_theme()->get('Version');
    wp_enqueue_style('afc-base', get_stylesheet_uri(), array(), $v);
    wp_enqueue_style('afc-site', get_template_directory_uri() . '/assets/css/site.css', array('afc-base'), $v);
    wp_enqueue_script('afc-main', get_template_directory_uri() . '/assets/js/main.js', array(), $v, true);
}
add_action('wp_enqueue_scripts', 'afc_assets');

function afc_customizer($wp_customize) {
    $wp_customize->add_section('afc_company', array('title' => __('Company contact details', 'agrofoodchain'), 'priority' => 35));
    $wp_customize->add_setting('afc_contact_email', array('default' => '', 'sanitize_callback' => 'sanitize_email'));
    $wp_customize->add_control('afc_contact_email', array('label' => __('Public company email', 'agrofoodchain'), 'section' => 'afc_company', 'type' => 'email'));
    $wp_customize->add_setting('afc_contact_phone', array('default' => '', 'sanitize_callback' => 'sanitize_text_field'));
    $wp_customize->add_control('afc_contact_phone', array('label' => __('Public company phone', 'agrofoodchain'), 'section' => 'afc_company', 'type' => 'text'));
}
add_action('customize_register', 'afc_customizer');

function afc_nav_fallback($args = array()) {
    echo '<ul class="nav-list" id="primary-menu">';
    $items = array(
      array('Home','/'), array('About Us','/about/'), array('Services','/services/'),
      array('Industries','/industries/'), array('Development Projects','/development-projects/'),
      array('International Buyers','/international-buyers/'), array('Insights','/insights/'),
      array('Contact','/contact/')
    );
    foreach ($items as $i) {
        echo '<li><a href="' . esc_url(home_url($i[1])) . '">' . esc_html($i[0]) . '</a></li>';
    }
    echo '</ul>';
}

function afc_meta_description() {
    // Avoid outputting duplicate descriptions if a mainstream SEO plugin is active.
    if (defined('WPSEO_VERSION') || defined('RANK_MATH_VERSION') || defined('AIOSEO_VERSION')) { return; }
    if (is_front_page()) {
        $desc = 'Independent supplier audits, certification support, food safety, agricultural standards, social compliance and ESG advisory for organisations operating across Central Asia.';
    } elseif (is_singular()) {
        $desc = get_the_excerpt();
        if (!$desc) { $desc = wp_strip_all_tags(get_the_content()); }
        $desc = wp_trim_words($desc, 25, '…');
    } else {
        $desc = get_bloginfo('description');
    }
    if ($desc) { echo '<meta name="description" content="' . esc_attr($desc) . '">' . "\n"; }
}
add_action('wp_head', 'afc_meta_description', 1);

function afc_organization_jsonld() {
    if (!is_front_page()) { return; }
    $data = array(
        '@context' => 'https://schema.org', '@type' => 'Organization',
        'name' => 'AGRO FOOD CHAIN LLC', 'url' => home_url('/'),
        'description' => 'Auditing, certification support and business consulting services across Central Asia.',
        'areaServed' => array('Uzbekistan', 'Kazakhstan', 'Kyrgyzstan', 'Tajikistan', 'Turkmenistan')
    );
    $email = get_theme_mod('afc_contact_email', '');
    if ($email) { $data['email'] = $email; }
    echo '<script type="application/ld+json">' . wp_json_encode($data, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) . '</script>' . "\n";
}
add_action('wp_head', 'afc_organization_jsonld', 30);

function afc_excerpt_more() { return '…'; }
add_filter('excerpt_more', 'afc_excerpt_more');
