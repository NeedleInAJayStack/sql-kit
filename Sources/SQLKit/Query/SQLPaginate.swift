
public protocol SQLPaginatable {

    /// Zero or more `ORDER BY` clauses.
    var orderBy: [SQLExpression] { get set }

    /// If set, limits the maximum number of results.
    var limit: Int? { get set }
    
    /// If set, offsets the results.
    var offset: Int? { get set }
}

extension SQLPaginatable {
    public func serializePagination(to serializer: inout SQLSerializer) {
        if !self.orderBy.isEmpty {
            serializer.write(" ORDER BY ")
            SQLList(self.orderBy).serialize(to: &serializer)
        }
        if let limit = self.limit {
            serializer.write(" LIMIT ")
            serializer.write(limit.description)
        }
        if let offset = self.offset {
            serializer.write(" OFFSET ")
            serializer.write(offset.description)
        }
    }
}
