import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { schedule } from "@ember/runloop";
import DButton from "discourse/components/d-button";
import I18n from "discourse-i18n";
import { htmlSafe } from "@ember/template";

const SCENE_CONTAINER_START = htmlSafe("<div class=\"animated-scene-toggle__container\">");
const DARK_REGION_1 = htmlSafe("PASTE_FROM_PACKAGED_FILE");
const DARK_REGION_2 = htmlSafe("PASTE_FROM_PACKAGED_FILE");
const DARK_REGION_3 = htmlSafe("PASTE_FROM_PACKAGED_FILE");
const DARK_REGION_4 = htmlSafe("PASTE_FROM_PACKAGED_FILE");
const DARK_REGION_5 = htmlSafe("PASTE_FROM_PACKAGED_FILE");
const LIGHT_REGION_1 = htmlSafe("PASTE_FROM_PACKAGED_FILE");
const LIGHT_REGION_2 = htmlSafe("PASTE_FROM_PACKAGED_FILE");
const LIGHT_REGION_3 = htmlSafe("PASTE_FROM_PACKAGED_FILE");
const LIGHT_REGION_4 = htmlSafe("PASTE_FROM_PACKAGED_FILE");
const LIGHT_REGION_5 = htmlSafe("PASTE_FROM_PACKAGED_FILE");

export default class AnimatedSceneToggle extends Component {
  @service currentUser;
  @service themeSelector;

  @tracked isLightMode = false;

  get sceneMarkup() {
    return [
      SCENE_CONTAINER_START,
      DARK_REGION_1,
      DARK_REGION_2,
      DARK_REGION_3,
      DARK_REGION_4,
      LIGHT_REGION_1,
      LIGHT_REGION_2,
      LIGHT_REGION_3,
      LIGHT_REGION_4,
    ];
  }

  constructor() {
    super(...arguments);
    this.syncState();
    this.observeRootThemeChanges();
  }

  willDestroy() {
    super.willDestroy(...arguments);
    this._observer?.disconnect();
  }

  get shouldRender() {
    return settings.show_for_anons || !!this.currentUser;
  }

  get buttonClass() {
    const classes = ["animated-scene-toggle-header-button"];
    classes.push(this.isLightMode ? "light-mode" : "dark-mode");

    if (settings.compact_mode) {
      classes.push("is-compact");
    }

    return classes.join(" ");
  }

  get title() {
    return this.isLightMode
      ? I18n.t(themePrefix("animated_scene_toggle.switch_to_dark"))
      : I18n.t(themePrefix("animated_scene_toggle.switch_to_light"));
  }

  get debugText() {
    if (!settings.debug_mode) {
      return null;
    }

    return I18n.t(themePrefix("animated_scene_toggle.render_ready"));
  }

  syncState() {
    const root = document.documentElement;
    this.isLightMode =
      !root.classList.contains("dark") &&
      root.dataset.themeColorScheme !== "dark";

    schedule("afterRender", this, this.applySceneModeClass);
  }

  observeRootThemeChanges() {
    if (this._observer) {
      return;
    }

    this._observer = new MutationObserver(() => this.syncState());
    this._observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ["class", "data-theme-color-scheme"],
    });
  }

  async applyScheme(mode) {
    if (this.themeSelector?.setLocalThemeBasedOnColorScheme) {
      await this.themeSelector.setLocalThemeBasedOnColorScheme(mode);
      return;
    }

    if (this.themeSelector?.setColorScheme) {
      await this.themeSelector.setColorScheme(mode);
      return;
    }

    const root = document.documentElement;
    root.classList.toggle("dark", mode === "dark");
    root.dataset.themeColorScheme = mode;
  }

  applySceneModeClass() {
    const root = document.querySelector(
      ".animated-scene-toggle-header-button .animated-scene-toggle__scene-root"
    );

    if (!root) {
      return;
    }

    root.classList.toggle("light-mode", this.isLightMode);
    root.classList.toggle("dark-mode", !this.isLightMode);
  }

  @action
  sceneInserted() {
    this.applySceneModeClass();
  }

  @action
  async toggleTheme() {
    const nextMode = this.isLightMode ? "dark" : "light";
    await this.applyScheme(nextMode);
    this.isLightMode = nextMode === "light";
    this.applySceneModeClass();
  }

  <template>
    {{#if this.shouldRender}}
      <li class="animated-scene-toggle-item">
        <DButton
          @action={{this.toggleTheme}}
          class={{this.buttonClass}}
          title={{this.title}}
          aria-label={{this.title}}
        >
          <span class="animated-scene-toggle__inner" aria-hidden="true">
            <span
              class="animated-scene-toggle__scene-root"
              {{did-insert this.sceneInserted}}
            >
              {{#each this.sceneMarkup as |region|}}
                {{region}}
              {{/each}}
            </span>
          </span>
          {{#if this.debugText}}
            <span class="animated-scene-toggle__debug-text">{{this.debugText}}</span>
          {{/if}}
        </DButton>
      </li>
    {{/if}}
  </template>
}
