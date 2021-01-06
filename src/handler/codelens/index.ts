import { NeovimClient as Neovim } from '@chemzqm/neovim'
import { Disposable } from 'vscode-languageserver-protocol'
import events from '../../events'
import BufferSync from '../../model/bufferSync'
import { ConfigurationChangeEvent } from '../../types'
import { disposeAll } from '../../util'
import workspace from '../../workspace'
import CodeLensBuffer, { CodeLensConfig } from './buffer'
const logger = require('../../util/logger')('codelens')

/**
 * Show codeLens of document, works on neovim only.
 */
export default class CodeLensManager {
  private config: CodeLensConfig
  private disposables: Disposable[] = []
  public buffers: BufferSync<CodeLensBuffer>
  constructor(private nvim: Neovim) {
    this.setConfiguration()
    workspace.onDidChangeConfiguration(e => {
      this.setConfiguration(e)
    }, null, this.disposables)
    this.buffers = workspace.registerBufferSync(doc => {
      if (doc.buftype != '') return undefined
      return new CodeLensBuffer(nvim, doc.bufnr, this.config)
    })
    events.on('ready', () => {
      this.checkProvider()
    }, null, this.disposables)
    events.on('CursorMoved', bufnr => {
      let buf = this.buffers.getItem(bufnr)
      if (buf) buf.resolveCodeLens()
    }, null, this.disposables)
    // Refresh on CursorHold
    let forceFetch = async bufnr => {
      let buf = this.buffers.getItem(bufnr)
      if (buf) await buf.forceFetch()
    }
    events.on('CursorHold', forceFetch, this, this.disposables)
  }

  /**
   * Check provider for buf that not fetched
   */
  public checkProvider(): void {
    for (let buf of this.buffers.items) {
      if (buf.hasProvider) {
        buf.fetchCodelenses()
      }
    }
  }

  private setConfiguration(e?: ConfigurationChangeEvent): void {
    if (e && !e.affectsConfiguration('codeLens')) return
    let config = workspace.getConfiguration('codeLens')
    let enable: boolean = this.nvim.hasFunction('nvim_buf_set_virtual_text') && config.get<boolean>('enable', false)
    if (e && enable != this.config.enabled) {
      for (let buf of this.buffers.items) {
        if (enable) {
          buf.forceFetch().logError()
        } else {
          buf.clear()
        }
      }
    }
    this.config = Object.assign(this.config || {}, {
      enabled: enable,
      separator: config.get<string>('separator', '‣'),
      subseparator: config.get<string>('subseparator', ' ')
    })
  }

  public async doAction(): Promise<void> {
    let { nvim } = this
    let bufnr = await nvim.call('bufnr', '%')
    let line = (await nvim.call('line', '.') as number) - 1
    let buf = this.buffers.getItem(bufnr)
    await buf?.doAction(line)
  }

  public dispose(): void {
    this.buffers.dispose()
    disposeAll(this.disposables)
  }
}
