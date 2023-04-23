import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['form', 'errors'];

  reset() {
    if (!event.detail.success) return;

    if (this.hasErrorsTarget) this.errorsTarget.innerHTML = '';

    this.formTarget.classList.remove('has-errors');
    this.formTarget.reset();
  }
}
