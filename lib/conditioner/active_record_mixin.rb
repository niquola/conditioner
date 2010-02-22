module Conditioner
  module ActiveRecordMixin
    def conditioner(params=nil)
      cnd = Conditioner::Condition.new(self)
      cnd.extract params if params
      cnd
    end
  end
end
