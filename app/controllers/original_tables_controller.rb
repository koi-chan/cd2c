class OriginalTablesController < ApplicationController
  before_action :require_sign_in, only: %i(new create edit update destroy)

  def index
    @original_tables = OriginalTable.public?(current_user&.id)
  end

  def new
    @original_table = OriginalTable.new
  end

  def create
    @original_table = OriginalTable.new(params_for_create)
    @original_table.user = current_user

    if @original_table.save
      flash[:success] = t('views.flash.added_original_table')
      redirect_to(original_table_path(@original_table))
    else
      render(:new)
    end
  end

  def edit
    @original_table = OriginalTable.find(params[:id])

    unless(@original_table.user == current_user)
      flash[:abort] = t('views.flash.edit_original_table_can_author_only')
      redirect_to(original_table_path(@original_table))
    end
  end

  def show
    @original_table = OriginalTable.find(params[:id])

    unless(@original_table.public || @original_table.user == current_user)
      flash[:abort] = t('views.flash.show_original_table_can_author_only')
      redirect_to(original_tables_path)
    end
  end

  def update
    @original_table = OriginalTable.find(params[:id])

    unless(@original_table.user == current_user)
      flash[:abort] = t('views.flash.edit_original_table_can_author_only')
      redirect_to(original_table_path(@original_table))
    end

    if(@original_table.update(params_for_update))
      flash[:success] = t('views.flash.updated_original_table')
      redirect_to(original_table_path(@original_table))
    else
      render(:edit)
    end
  end

  def destroy
    @original_table = OriginalTable.find(params[:id])

    unless(@original_table.user == current_user)
      flash[:abort] = t('views.flash.edit_original_table_can_author_only')
      redirect_to(original_table_path(@original_table))
    end

    if(@original_table.destroy)
      flash[:success] = t('views.flash.deleted_original_table')
      redirect_to(original_tables_path)
    else
      render(:show)
    end
  end

  private

  def params_for_create
    params.
      require(:original_table).
      permit(:name, :definition, :public)
  end

  def params_for_update
    params.
      require(:original_table).
      permit(:definition, :public)
  end
end
