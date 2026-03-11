import { List, useTable } from "@refinedev/antd";
import { Table } from "antd";
export function PostList() {
  const { tableProps } = useTable({
    resource: "posts",
  });
  return (
    <List>
      <Table {...tableProps} rowKey="id">
        <Table.Column dataIndex="id" title="ID" />
        <Table.Column dataIndex="title" title="Title" />
      </Table>
    </List>
  );
}
