<script setup lang="ts">
import { ref } from 'vue'
import { withBase } from 'vitepress'
import './landing.css'

const active = ref(0)
const steps = [
  { title: 'Choose a schema', text: 'Start with the type of data you want to validate.' },
  { title: 'Compose your rules', text: 'Combine built-in rules to describe what valid means.' },
  { title: 'Read the result', text: 'Get the validated data or a list of helpful errors.' },
]
</script>

<template>
  <div class="landing">
    <header class="landing-nav wrap">
      <a class="wordmark" :href="withBase('/')" aria-label="Validasi home"><img class="brand-mark" :src="withBase('/logo.png')" alt="">validasi<span class="wordmark-dot">.</span></a>
      <nav aria-label="Main navigation"><a :href="withBase('/guide/getting-started')">Docs</a><a href="https://pub.dev/documentation/validasi/latest/">API reference</a><a href="https://github.com/albetnov/validasi">GitHub <span aria-hidden="true">↗</span></a></nav>
    </header>
    <main>
      <section class="hero wrap">
        <h1>Validation, mapped<br class="desktop-break"> to your data<span class="title-dot">.</span></h1>
        <div class="hero-bottom"><p>Build type-safe rules for Dart and Flutter, one clear schema at a time.</p><a class="button primary" :href="withBase('/guide/getting-started')">Start the guide <span aria-hidden="true">↗</span></a></div>
        <div class="atlas" aria-label="An example of a Validasi schema">
          <div class="atlas-head"><span>A CLOSER LOOK</span><span>STRING SCHEMA <span class="atlas-symbol">✳</span></span></div>
          <div class="atlas-content">
            <div class="code-column">
              <div class="code-caption"><span class="code-dot"></span> schema.dart</div>
              <pre aria-label="Dart validation example"><code><span :class="{ selected: active === 0 }"><span class="muted-code">final</span> schema = <span class="bright-code">Validasi.string</span>([</span>
<span :class="{ selected: active === 1 }">  Rules.string.<span class="bright-code">minLength</span>(<span class="code-number">3</span>),
  Rules.string.<span class="bright-code">maxLength</span>(<span class="code-number">16</span>),</span>
<span :class="{ selected: active === 0 }">]);</span>

<span :class="{ selected: active === 2 }"><span class="muted-code">final</span> result = schema.<span class="bright-code">validate</span>(<span class="code-string">'Hello'</span>);</span></code></pre>
              <div class="result-line"><span class="result-check">✓</span><span>result.isValid</span><strong>true</strong></div>
            </div>
            <div class="atlas-notes" aria-label="Explore the example">
              <p class="notes-label">FOLLOW THE SCHEMA</p>
              <button v-for="(step, index) in steps" :key="step.title" type="button" :class="['atlas-step', { active: active === index }]" :aria-pressed="active === index" @click="active = index"><span class="step-marker" aria-hidden="true">{{ index + 1 }}</span><span><strong>{{ step.title }}</strong><small>{{ step.text }}</small></span><span class="step-arrow" aria-hidden="true">↗</span></button>
            </div>
          </div>
          <div class="atlas-foot"><span>INPUT <span aria-hidden="true">→</span> RULES <span aria-hidden="true">→</span> RESULT</span><span>MADE FOR DART & FLUTTER</span></div>
        </div>
        <div class="hero-tail"><span>LESS GUESSWORK. MORE GOOD DATA.</span><span>SCROLL TO EXPLORE ↓</span></div>
      </section>
      <section class="intro-section wrap"><div class="section-heading"><h2>Validation that<br>reads like your intent<span>.</span></h2></div><div class="intro-copy"><p>From a single string to a nested map, Validasi lets you describe your data with small rules that work together.</p><a class="text-link" :href="withBase('/guide/schemas')">Explore schemas <span aria-hidden="true">↗</span></a></div></section>
      <section class="capabilities wrap" aria-label="What you can do with Validasi">
        <article class="capability feature-large"><h3>Small rules.<br>Big picture.</h3><p>Bring built-in and custom rules together in a schema that fits your data.</p><div class="rule-chain" aria-hidden="true"><span>required</span><i>+</i><span>email</span><i>+</i><span>custom</span></div></article>
        <article class="capability feature-light"><h3>Prepare as<br>you validate.</h3><p>Trim, normalize, or preprocess values as part of your validation flow.</p><div class="transform-demo" aria-hidden="true"><span>“ Hello ”</span><span>→</span><strong>“hello”</strong></div></article>
        <article class="capability feature-outline"><h3>Know where<br>it went wrong.</h3><p>Get errors with messages and paths that point to the part of your data that needs attention.</p><div class="error-demo"><span>profile.email</span><strong>Invalid email</strong></div></article>
      </section>
      <section class="ecosystem wrap"><div><h2>Fits the way<br>you work<span>.</span></h2></div><div class="ecosystem-list"><a :href="withBase('/companion/generator/overview')"><span><strong>Code generation</strong><small>Generate typed validators and field classes at build time.</small></span><span aria-hidden="true">↗</span></a><a :href="withBase('/companion/form-management/overview')"><span><strong>Flutter form management</strong><small>Connect validation to your forms with headless tools.</small></span><span aria-hidden="true">↗</span></a><a :href="withBase('/advanced/custom-rule')"><span><strong>Custom rules</strong><small>Extend validation for the needs of your project.</small></span><span aria-hidden="true">↗</span></a></div></section>
      <section class="closing wrap"><div><h2>Ready to make<br>your data make sense?</h2><p>Start with a schema. Take it wherever your project needs to go.</p></div><a class="button closing-button" :href="withBase('/guide/getting-started')">Get started <span aria-hidden="true">↗</span></a></section>
    </main>
    <footer class="landing-footer wrap"><a class="wordmark" :href="withBase('/')">validasi<span class="wordmark-dot">.</span></a><p>Type-safe validation for Dart & Flutter.</p><div><a :href="withBase('/guide/getting-started')">Documentation</a><a href="https://github.com/albetnov/validasi">GitHub</a><a href="https://pub.dev/packages/validasi">pub.dev</a></div><small>Released under the MIT License.</small></footer>
  </div>
</template>
