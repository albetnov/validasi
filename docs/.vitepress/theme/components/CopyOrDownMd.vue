<template>
	<div class="markdown-copy-buttons" aria-label="Page markdown actions">
		<button
			ref="copyBtn"
			class="ghost-button"
			title="Copy markdown"
			aria-label="Copy markdown"
			@click="copyMarkdown"
		>
			<span v-html="copied ? iconCheck : iconCopy"></span>
		</button>
		<button
			ref="downloadBtn"
			class="ghost-button"
			title="Download markdown"
			aria-label="Download markdown"
			@click="downloadMarkdown"
		>
			<span v-html="downloaded ? iconCheck : iconDownload"></span>
		</button>
	</div>
</template>

<script setup lang="ts">
/** biome-ignore-all lint/correctness/noUnusedVariables: cuz it Vue o((>ω< ))o */
import { ref } from 'vue'
import { downloadFile, resolveMarkdownPageURL } from './utils'

//#region SVG Icons
const iconCheck =
	'<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-check-icon lucide-check"><path d="M20 6 9 17l-5-5"/></svg>'
const iconCopy =
	'<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-copy-icon lucide-copy"><rect width="14" height="14" x="8" y="8" rx="2" ry="2"/><path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"/></svg>'
const iconDownload =
	'<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-download-icon lucide-download"><path d="M12 15V3"/><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><path d="m7 10 5 5 5-5"/></svg>'
//#endregion

const copied = ref(false)
const downloaded = ref(false)

const currentURL = window.location.origin + window.location.pathname

/** Copies markdown content from the current page to clipboard */
function copyMarkdown() {
	fetch(resolveMarkdownPageURL(currentURL))
		.then((response) => response.text())
		.then((text) => navigator.clipboard.writeText(text))
		.then(() => {
			copied.value = true
			setTimeout(() => {
				copied.value = false
			}, 2000)
		})
		.catch((error) => console.error('❌ Error copying markdown:', error))
}

/** Downloads markdown content from the current page as a file */
function downloadMarkdown() {
	const markdownPageUrl = resolveMarkdownPageURL(currentURL)
	fetch(markdownPageUrl)
		.then((response) => response.text())
		.then((text) => {
			const filename = markdownPageUrl.split('/').pop() || 'page.md'
			downloadFile(filename, text, 'text/markdown')

			downloaded.value = true
			setTimeout(() => {
				downloaded.value = false
			}, 2000)
		})
		.catch((error) => console.error('❌ Error downloading markdown:', error))
}
</script>

<style scoped>
.markdown-copy-buttons {
	width: 100%;
	display: flex;
	justify-content: flex-end;
	gap: 0.6rem;
	margin: 1.5rem 0 1rem;
}

.ghost-button {
	min-width: 46px;
	height: 46px;
	border-radius: 50%;
	border: 1.5px solid rgba(0, 123, 231, 0.65);
    color: rgba(0, 123, 231, 1);
	backdrop-filter: blur(12px);
	-webkit-backdrop-filter: blur(12px);
	display: inline-flex;
	align-items: center;
	justify-content: center;
	padding: 0.35rem;
	transition: all 0.2s ease;
	cursor: pointer;
}

.ghost-button:hover {
	transform: translateY(-2px);
	border-color: var(--vp-c-brand-2);
	box-shadow: 0 10px 20px rgba(30, 136, 229, 0.2);
}

.ghost-button:focus-visible {
	outline: 2px solid var(--vp-c-brand-2);
	outline-offset: 2px;
}

.ghost-button span {
	display: inline-flex;
}

.ghost-button svg {
	width: 18px;
	height: 18px;
}

.dark .ghost-button {
	background: rgba(2, 23, 72, 0.85);
	border-color: rgba(20, 202, 249, 0.65);
	color: var(--vp-c-brand-2);
}

.dark .ghost-button:hover {
	border-color: var(--vp-c-brand-2);
	box-shadow: 0 10px 20px rgba(15, 23, 42, 0.6);
}
</style>